# *NIF_2: `SEGAULT` because of faulty NIF (`MagicEightBall`).

**Assignment name**: `NIF_2`

**Topic**: *gdb* / *Core Dump*

## Description

Our "awesome" *NIF* caused whole *VM* to crash. And not even to the `erl_crash.dump`, but to the *core dump*. Are we doomed? Nope, we can debug and solve it!

## How to show it?

Persist command that is longer than 256 characters, and then try to restore it.

```bash
~ $ iex -S mix
```

```elixir
iex(...)1> MagicEightBall.Server.question?("Very long and winded up question, with a lot of words ...")
```

Remember to use a `prod` release, or you will have to change default configuration.