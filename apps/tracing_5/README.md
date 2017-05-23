# *TRACING_5*: Tracking down issue inside `ClientAndServer` application.

**Assignment name**: `TRACING_5`

**Topic**: `:sasl` + *Tracing*

## Description

In this assignment we would like to show you problem that is partially related with wrong design and how we can tackle it - for detecting root cause we will use `:sasl` and a bit of *tracing*.

## How to show it?

When you will start this application in normal way:

```bash
~ $ iex -S mix
```

You can start a *client* which will talk with server over very simple *TCP* protocol. As an effect you will see periodic prints on the console:

```elixir
iex(...)> ClientAndServer.Client.PoolSupervisor.start_client()
{:ok, #PID<...>}
iex(...)> ClientAndServer.Client.PoolSupervisor.start_client()
{:ok, #PID<...>}
iex(...)> ClientAndServer.Client.PoolSupervisor.start_client()
{:ok, #PID<...>}
iex(...)> ClientAndServer.Client.PoolSupervisor.start_client()
{:ok, #PID<...>}
iex(...)> ClientAndServer.Client.PoolSupervisor.start_client()
{:ok, #PID<...>}
iex(...)> 
23:29:04.092 [info]  Sent:     Q9+6hpgWvRrcd7VLKKWVdjLX5vg=
23:29:04.092 [info]  Received: Q9+6hpgWvRrcd7VLKKWVdjLX5vg=, Equal: true
...
```

So far so good. But let's see what will happen if we stop the *server*. In order to visualize we will enable `:observer` too.

```elixir
iex(...)> :observer.start()
iex(...)> ClientAndServer.stop_server()
```

It will explode and roll up supervision tree. That's not a good behavior. Let's investigate what happened.
