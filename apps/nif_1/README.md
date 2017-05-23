# *NIF_1: *Hogging Schedulers* because of faulty NIF (`MagicEightBall`).

**Assignment name**: `NIF_1`

**Topic**: *Schedulers* / *System Monitors*

## Description

Okay, we can start and check out either `IEx` session or `prod` release. Why it behaves so sluggish?

## How to show it?

```bash
~ $ MIX_ENV=prod mix release

# Open two `IEx` sessions:
~ $ _build/prod/rel/magic_eight_ball/bin/magic_eight_ball console
~ $ iex --name remsh@127.0.0.1 --remsh magic_eight_ball@127.0.0.1 --cookie "PROD_COOKIE"
```

And then in second one spawn this (you can read about this module below):

```elixir
iex(...)1> TempSysMon.start({:long_schedule, 200})
```

And in first one try to invoke this:

```elixir
iex(...)1> for i <- 0..10_000, do: MagicEightBall.Server.question?("Question number #{i}?")
```

After that will notice the following:

```elixir
iex(...)1> TempSysMon.start({:long_schedule, 200})
#PID<0.1086.0>
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 124, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
---                               
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 109, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
---                               
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 113, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
---                               
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 142, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
---                               
monitor=long_schedule pid=#PID<0.870.0> info=[timeout: 111, in: {:gen_server, :loop, 6}, out: {:gen_server, :loop, 6}]
```