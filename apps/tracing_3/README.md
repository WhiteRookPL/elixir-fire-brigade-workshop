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

## Detecting root cause

Tracing will show that `handle_info(:timeout, _, _)` was not called at all. Why? When you enables tracing with `:sys` module you will see that scheduled `:timeout` timer was cancelled after receiving first message into the `Printer` process queue.

When it comes to main mechanism used inside our behaviour we've made one significant mistake. Initial `:timeout` for `GenServer` needs *silence* when it comes to incoming messages.

If you will receive any message (*call*, *cast* or *info*) before timeout will fire, it will be cancelled out.

We need to change internal mechanism to plain `handle_info` messages, without relying on `:timeout`.

## Fix

**Tag**: `FIX_FOR_TRACING_3`

```diff
diff --git a/apps/tracing_3/lib/periodic_gen_server.ex b/apps/tracing_3/lib/periodic_gen_server.ex
index f5757e2..c4c7202 100644
--- a/apps/tracing_3/lib/periodic_gen_server.ex
+++ b/apps/tracing_3/lib/periodic_gen_server.ex
@@ -41,7 +41,9 @@ defmodule PeriodicGenServerApp.Behaviour do
           fn() -> module.handle_periodic_operation(additonal_state) end
         )
 
-        {:ok, {module, frequency, update_state}, frequency}
+        Process.send_after(self(), :tick, frequency)
+
+        {:ok, {module, frequency, update_state}}
 
       {:error, reason} ->
         {:stop, reason}
@@ -61,13 +63,13 @@ defmodule PeriodicGenServerApp.Behaviour do
     {:reply, result, state}
   end
 
-  def handle_info(:timeout, {module, frequency, internal_state}) do
+  def handle_info(:tick, {module, frequency, internal_state}) do
     new_state = case module.handle_periodic_operation(internal_state) do
         {:ok, changed_state} -> changed_state;
         {:error, _reason}    -> internal_state
     end
 
-    Process.send_after(self(), :timeout, frequency)
+    Process.send_after(self(), :tick, frequency)
 
     {:noreply, {module, frequency, new_state}}
   end
diff --git a/apps/tracing_3/lib/supervisor.ex b/apps/tracing_3/lib/supervisor.ex
index c867af0..579be1e 100644
--- a/apps/tracing_3/lib/supervisor.ex
+++ b/apps/tracing_3/lib/supervisor.ex
@@ -7,10 +7,8 @@ defmodule PeriodicGenServerApp.Supervisor do
 
   def init(:ok) do
     children = [
-      worker(PeriodicGenServerApp.Printer, [])
-
-      # After enabling this line our PeriodicGenServer stops working:
-      # worker(PeriodicGenServerApp.Interrogator, [])
+      worker(PeriodicGenServerApp.Printer, []),
+      worker(PeriodicGenServerApp.Interrogator, [])
     ]
 
     supervise(children, strategy: :one_for_one)

```