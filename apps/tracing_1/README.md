# *TRACING_1*: Why Phoenix spawns 100 *HTTP* acceptors by default?

**Assignment name**: `TRACING_1`

**Topic**: *Tracing*

## Description

There is one thing that makes use of `:observer` painful - there are too many acceptors by default spawned by *Phoenix*. If you will look on it - with defailt settings, there is at least a 100 of them.

## How to show it?

Open the application:

```bash
~ $ iex -S mix phx.server
```

Open the `:observer`:

```elixir
iex(...)> :observer.start()
```

And go to the `RestApi` application and show the graph. Too many to be legible. :confused: