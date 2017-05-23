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