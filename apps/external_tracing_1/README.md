# *EXTERNAL_TRACING_1*: Example session with *lttng* for *Erlang VM*

**Assignment name**: `EXTERNAL_TRACING_1`

**Topic**: External Tracing (*lttng*)

## Description

This application is an additional task that will allow us to show *lttng* support for external tracing facilities (in this case *lttng* - as it may be the most popular choice for server side environment).

If you want to install it, you can find *ArchLinux* example inside (helpers)[https://github.com/WhiteRookPL/elixir-fire-brigade-workshop/blob/master/helpers/commands.md#external-tracing-for-beam-with-lttng], however bear in mind that it is not exactly a *production-ready* recipe, rather a demo how to approach external tracing.

## Example Session

```bash
~ $ lttng create erlang-demo-session
Spawning a session daemon
Session erlang-demo-session created.
Traces will be written in ~/lttng-traces/erlang-demo-session-20170812-190840

# All probes are under `org_erlang_dyntrace` namespace:

~ $ lttng enable-event -u org_erlang_dyntrace:process_register
UST event org_erlang_dyntrace:process_register created in channel channel0

~ $ lttng start
Tracing started for session erlang-demo-session

~ $ iex -S mix
Erlang/OTP 19 [erts-8.2] [source] [64-bit] [smp:8:8] [async-threads:10] [kernel-poll:false] [lttng]
Interactive Elixir (1.5.0) - press Ctrl+C to exit (type h() ENTER for help)
iex(...)> ...

~ $ lttng enable-event -j lttng_example:work
UST event lttng_example:work created in channel channel0
```

Let's call once `LttngExample.Worker.work/0` from our application:

```elixir
iex(...)> LttngExample.Worker.work()
:worked
```

And we can look into collected traces:

```bash
~ $ lttng stop
Waiting for data availability
Tracing stopped for session erlang-demo-session

~ $ lttng view
Trace directory: /home/afronski/lttng-traces/erlang-demo-session-20170812-190840

[19:11:31.324663144] (+?.?????????) localhost org_erlang_dyntrace:process_register: { cpu_id = 4 }, { pid = "<0.171.0>", name = "'Elixir.LttngExample.Worker'", type = "register" }

[19:11:32.810789887] (+?.?????????) localhost lttng_jul:user_erlang_trace: { cpu_id = 3 }, { pid = "<0.33.0>", type = "call", msg = "{erlang,display,[[]]}" }
```

And now we can play in more details with other probes exposed by *BEAM* and add our custom probes too (see example inside code).

## Fix

There is no fix needed for that assignment - it is about showing *external tracing* facilities available on *Erlang VM*.