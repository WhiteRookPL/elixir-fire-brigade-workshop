# *TOOLS_1*: Infinite loop in `RandomServer`

**Assignment name**: `TOOLS_1`

**Topic**: `:etop`

## Description

By accident one of our GenServers contains an infinite loop. Let's tackle this problem!

## How to show it?

First we need to gather some history, one command is enough:

```bash
~ $ iex -S mix
```

```elixir
iex(...)1> RandomServer.Randomizer.rand()   
{:result, 0.9916260417448395}

iex(...)2> RandomServer.Randomizer.range(5, 10)
{:result, 6}

iex(...)3> RandomServer.Randomizer.randomize_list([ 1, 2, 3 ])
{:result, [3, 2, 1]}

iex(...)4> RandomServer.Randomizer.change_algorithm(:exs1024)
{:changed,
 {%{max: 18446744073709551615, next: #Function<4.41921595/1 in :rand.mk_alg/1>,
    type: :exs1024, uniform: #Function<5.41921595/1 in :rand.mk_alg/1>,
    uniform_n: #Function<6.41921595/2 in :rand.mk_alg/1>},
  {[11332585097264771995, 13990241512553620391, 1411789589046166709,
    3261083870246438848, 9720286778218566471, 17384754948704142882,
    6880984127160874864, 6458555264865887849, 15943274152880363524,
    12031984709629644658, 7734331521223066552, 9465022795869519123,
    3070165409410490306, 6415622625191346282, 9798824531234856654,
    15537885825254126896], []}}}

iex(...)5> RandomServer.Randomizer.history()  
```

And now we will see one-two cores **utilized** in 100%:

```bash
~ $ htop
```

## Detecting root cause

And inside Erlang we can clearly see which call and process is it:

```elixir
iex(...)1> :etop.start(interval: 0.5, sort: :reductions)
iex(...)2> :recon.proc_window(:reductions, 1, 1000)
```

Unfortunately current function is cut off there, but we can tackle it in different way:

```elixir
iex(...)1> Process.info(pid(p, i, d), :current_function)
```

We will see that responsible one is `Elixir.RandomServer.Randomizer.prepare/2`.

## Fix

**Tag**: `FIX_FOR_TOOLS_1`

```diff
diff --git a/apps/tools_1/lib/randomizer.ex b/apps/tools_1/lib/randomizer.ex
index 0be45df..6fcec17 100644
--- a/apps/tools_1/lib/randomizer.ex
+++ b/apps/tools_1/lib/randomizer.ex
@@ -95,6 +95,6 @@ defmodule RandomServer.Randomizer do
   end
 
   defp prepare([], acc), do: acc
-  defp prepare([ {command, result} | _tail ] = list, acc) when is_list(result), do: prepare(list, [ "#{command} = #{inspect result}" | acc ])
-  defp prepare([ {command, result} | _tail ] = list, acc), do: prepare(list, [ "#{command} = #{result}" | acc ])
+  defp prepare([ {command, result} | tail ], acc) when is_list(result), do: prepare(tail, [ "#{command} = #{inspect result}" | acc ])
+  defp prepare([ {command, result} | tail ], acc), do: prepare(tail, [ "#{command} = #{result}" | acc ])
 end
\ No newline at end of file
diff --git a/apps/tools_1/test/randomizer_test.exs b/apps/tools_1/test/randomizer_test.exs
index 3c6c17e..5723fdd 100644
--- a/apps/tools_1/test/randomizer_test.exs
+++ b/apps/tools_1/test/randomizer_test.exs
@@ -33,4 +33,10 @@ defmodule RandomServer.Randomizer.Test do
     assert {:result, shuffled} = RandomServer.Randomizer.randomize_list(original)
     assert shuffled != original
   end
+
+  test "that you should be able to commands history in random server" do
+    assert {:history, commands} = RandomServer.Randomizer.history()
+
+    assert length(commands) == 6
+  end
 end
\ No newline at end of file
```

And quick verification:

```bash
~ $ mix test --seed 0
```