# *TRACING_3*: Debugging a bug in custom behavior (`PeriodicGenServerApp`)

**Assignment name**: `TRACING_3`

**Topic**: `:sys` + *Tracing*

## Description

We have implemented custom behavior called `PeriodicGenServer` that basically wraps normal `GenServer` and allows to execute tasks in a periodic fashion.

It leverages `:timeout` mechanism for `GenServer` during `GenServer.init/1`.

However something is not working properly there.

## How to show it?

When you will start this application in normal way:

```bash
~ $ iex -S mix
```

You will see periodic prints on the console from `Printer` process. However after uncommenting line 13 in `supervisor.ex`:

```elixir
  def init(:ok) do
    children = [
      worker(PeriodicGenServerApp.Printer, [])

      # After enabling this line our PeriodicGenServer stops working:
      # worker(PeriodicGenServerApp.Interrogator, [])
    ]
```

You will see only messages provided by `Interrogator` process. What happened? 