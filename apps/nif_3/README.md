# *NIF_3: *Internal memory leak* because of faulty NIF (`MagicEightBall`).

**Assignment name**: `NIF_3`

**Topic**: *Memory Leak* / *Memory Management*

## Description

This is the most flaky bug from today session. It is extremely hard to detect such memory leaks without `valgrind` - and when it comes to that tool, we need to remember that *VM* itself adds a lot of false positives to the picture (even exclusions are not helping). There is a list of them, attached to the source code - that allows to exclude those. Still - custom *Erlang VM* build, patching *valgrind* and a lot of false positives are not the ideal solution.

How to tackle it differently? Let's find out. 

## How to show it?

Start `IEx` session and look on *BEAM* memory usage on *OS* level after starting:

```bash
~ $ iex -S mix
```

And invoke those commands:

```elixir
iex(...)1> :erlang.memory()
iex(...)2> for i <- 0..10_000, do: MagicEightBall.Server.question?("Very long and winded up question that will finally eat memory and kill VM, maybe - maybe not I'm joking, right?")
```

And look on the memory usage again, on *OS* level metrics and compare them with *Erlang VM* ones:

```elixir
iex(...)1> :erlang.memory()
```

On *Erlang VM* side you will small increase, at least smaller than on the *OS* side, which means that we're allocating and not freeing memory outside of *ERTS* allocators.

## Detecting root cause

As we said setting up `valgrind` for *Erlang VM* is a complicated task, however we can tackle it, in a different way - but that's way is a workaround and it is *flaky*.

Let's create such module in the `iex` shell:

```elixir
defmodule NifLeakTest do
  def check() do
    before = :erlang.memory()
    pid = spawn_link(fn () ->
      MagicEightBall.Logic.question("ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD?"})
      receive do
        :cleanup -> :ok
      end
    end)

    :timer.sleep(:timer.seconds(2))
    during = :erlang.memory()

    send(pid, :cleanup)
    after_test = :erlang.memory()

    :lists.zipwith3(fn ({k, b}, {k, d}, {k, a}) ->
      leaked = a - b
      used = d - b
      {k, _values = {b, d, a}, {leaked, used}, {:leaked, leaked - used}}
    end, before, during, after_test)
  end
end
```

Or use those commands:

```erlang
iex(...)1> :recon_alloc.memory(:allocated)
iex(...)2> :recon_alloc.memory(:usage)
iex(...)3> :erlang.memory()
```

And here is the trick, you have do it in the most possible isolated environment, because *VM* itself will add noise to this example - if you execute one of commands from above couple times you will see trend in `system` memory grow, and that's our possible leak.

## Fix

**Tag**: `FIX_FOR_NIF_3`

```diff
diff --git a/apps/nif_3/c_src/magic_eight_ball_logic.c b/apps/nif_3/c_src/magic_eight_ball_logic.c
index c56f043..dbe40b2 100644
--- a/apps/nif_3/c_src/magic_eight_ball_logic.c
+++ b/apps/nif_3/c_src/magic_eight_ball_logic.c
@@ -110,6 +110,8 @@ static ERL_NIF_TERM question(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]
   int position = (random_from_range(0, SENTENCES_SIZE) + words) % SENTENCES_SIZE;
   const char* answer = SENTENCES[position];
 
+  enif_free(question);
+
   return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_string(env, answer, ERL_NIF_LATIN1));
 }
 

```
