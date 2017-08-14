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

## Detecting root cause

First we will enable `:sasl` and we will see almost everything. Finishing touch (detecting what happens during the initialization phase) can be done via tracing `:gen_tcp.connect/3` calls.

Main cause of this behaviour in our application is related with how client approaches the state management - it does not perform any reconnects, but also it assumes that during initialization server will be responding.

Instead we should initialize lazily our client, also by including reconnecting
mechanism into our implementation.

## Fix

**Tag**: `FIX_FOR_TRACING_5`

```diff
diff --git a/apps/tracing_5/lib/client/client_worker.ex b/apps/tracing_5/lib/client/client_worker.ex
index 2737b4b..d6b752a 100644
--- a/apps/tracing_5/lib/client/client_worker.ex
+++ b/apps/tracing_5/lib/client/client_worker.ex
@@ -4,19 +4,17 @@ defmodule ClientAndServer.Client.Worker do
   require Logger
 
   @tick_frequency_in_ms 3000
+  @reconnect_timeout_in_ms 1000
 
   def start_link() do
-    port = Application.get_env(:client_and_server, :port)
-    GenServer.start_link(__MODULE__, port)
+    GenServer.start_link(__MODULE__, :ok)
   end
 
-  def init(port) do
-    {:ok, socket} = :gen_tcp.connect('127.0.0.1', port, [ {:active, true} ])
-
-    Process.send_after(self(), :tick, @tick_frequency_in_ms)
+  def init(:ok) do
     value = :base64.encode(:crypto.strong_rand_bytes(20))
+    Process.send_after(self(), :reconnect, @reconnect_timeout_in_ms)
 
-    {:ok, {socket, "#{value}\n"}}
+    {:ok, {:undefined, "#{value}\n"}}
   end
 
   def handle_info({:tcp, _port, message}, {_socket, value} = state) do
@@ -26,6 +24,34 @@ defmodule ClientAndServer.Client.Worker do
     {:noreply, state}
   end
 
+  def handle_info({:tcp_closed, _port}, {_socket, value}) do
+    Process.send_after(self(), :reconnect, @reconnect_timeout_in_ms)
+    Logger.info("Connection closed.")
+
+    {:noreply, {:undefined, value}}
+  end
+
+  def handle_info(:reconnect, {_socket, value}) do
+    port = Application.get_env(:client_and_server, :port)
+    Logger.info("Connecting on #{port}...")
+
+    new_socket = case :gen_tcp.connect('127.0.0.1', port, [ {:active, true} ]) do
+      {:ok, socket} ->
+        Process.send_after(self(), :tick, @tick_frequency_in_ms)
+        socket
+
+      {:error, _}   ->
+        Process.send_after(self(), :reconnect, @reconnect_timeout_in_ms)
+        :undefined
+    end
+
+    {:noreply, {new_socket, value}}
+  end
+
+  def handle_info(:tick, {:undefined, _value} = state) do
+    {:noreply, state}
+  end
+
   def handle_info(:tick, {socket, value} = state) do
     Logger.info("Sent:     #{String.trim(value)}")
 
diff --git a/apps/tracing_5/mix.exs b/apps/tracing_5/mix.exs
index 0ede4a9..24d811b 100644
--- a/apps/tracing_5/mix.exs
+++ b/apps/tracing_5/mix.exs
@@ -23,7 +23,7 @@ defmodule ClientAndServer.Mixfile do
   end
 
   defp apps(env) when env == :test, do: []
-  defp apps(_), do: [ :lager, :logger ]
+  defp apps(_), do: [ :sasl, :lager, :logger ]
 
   defp deps() do
     [
```