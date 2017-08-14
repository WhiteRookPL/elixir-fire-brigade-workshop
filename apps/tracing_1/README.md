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

## Detecting root cause

We will use tracing for determining from where it comes, because:

1. If you will show Phoenix documentation (https://hexdocs.pm/phoenix/1.3.0/overview.html) and search for acceptors.
    - You will find nothing. :confused:
    - Beware, because it is in *Plug* docs! ;)
2. Check `ranch` acceptor (parent of those) in `:observer` and see the 100 in the parameters. Aha!
3. From where it comes? Let's trace (inside `RestApi.Application.start`):
    - `:redbug.start(~c[ranch_acceptors_sup:start_link->stack], msgs: 2)`
    - `:redbug.start(~c[ranch_listener_sup:start_link->stack], msgs: 2)`
    - `:redbug.start(~c['Elixir.Phoenix.Endpoint.Handler':init->stack], msgs: 2)`
    - One of the results is `Elixir.RestApi.Web.Endpoint` -> It is our module, that uses `Phoenix.Endpoint` macro.
    - There is `config` function that lookups `ets` table.
3. Check the `ets` table name.
4. `:redbug.start(~c[ets:insert('Elixir.RestApi.Web.Endpoint', _)->return;stack], msgs: 2)`
5. Now you can see this: `'Elixir.Phoenix.Config':init/1` - it means that it directly goes from configuration, with name `acceptors` from `http` setting.

## Fix

**Tag**: `FIX_FOR_TRACING_1`

```diff
diff --git a/apps/tracing_1/config/dev.exs b/apps/tracing_1/config/dev.exs
index 15a597d..0b841a1 100644
--- a/apps/tracing_1/config/dev.exs
+++ b/apps/tracing_1/config/dev.exs
@@ -7,7 +7,10 @@ use Mix.Config
 # watchers to your application. For example, we use it
 # with brunch.io to recompile .js and .css sources.
 config :rest_api, RestApiWeb.Endpoint,
-  http: [port: 4000],
+  http: [
+    port: 4000,
+    acceptors: 2
+  ],
   debug_errors: true,
   code_reloader: true,
   check_origin: false,
```

I know that it might be a far-fetched example, but I wanted to show you how we can tackle various problems with tracing at first.
