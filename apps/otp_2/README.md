# *OTP_2*: Debugging `:proc_lib` (`Chatterboxes`)

**Assignment name**: `OTP_2`

**Topic**: `:proc_lib` and *special processes*.

## Description

We've created application that elements are built on top of special processes (`:proc_lib`). And something is not working properly there. Let's debug this!

## How to show it?

```bash
~ $ iex -S mix
```

Wait for a bit and execute following command:

```elixir
iex(...)> Chatterboxes.Statistics.get_result()
%{}
```

That's not right - we should aggregate periodically elements that are coming from *a few blabbers*. Let's investigate which items are flowing through the system.

## Detecting root cause

We did couple of typos in message names and eventually after fixing those everything starts working properly.

## Fix

**Tag**: `FIX_FOR_OTP_2`

```diff
diff --git a/apps/otp_2/lib/statistics.ex b/apps/otp_2/lib/statistics.ex
index 47918ad..2867e9b 100644
--- a/apps/otp_2/lib/statistics.ex
+++ b/apps/otp_2/lib/statistics.ex
@@ -22,7 +22,7 @@ defmodule Chatterboxes.Statistics do
 
     seed = 1
 
-    Process.send_after(self(), :tick, @frequency_in_ms)
+    Process.send_after(self(), :aggregate, @frequency_in_ms)
 
     {:ok, {pending, jobs, refs, seed}}
   end
diff --git a/apps/otp_2/lib/statistics_aggregation_job.ex b/apps/otp_2/lib/statistics_aggregation_job.ex
index 2d0ac90..540cc74 100644
--- a/apps/otp_2/lib/statistics_aggregation_job.ex
+++ b/apps/otp_2/lib/statistics_aggregation_job.ex
@@ -48,7 +48,7 @@ defmodule Chatterboxes.Statistics.AggregationJob do
 
     :proc_lib.init_ack(parent, {:ok, self()})
 
-    send(self(), :agregation)
+    send(self(), :aggregation)
     loop(parent, opts, state)
   end
 
@@ -64,7 +64,7 @@ defmodule Chatterboxes.Statistics.AggregationJob do
 
         loop(parent, new_opts, %{state | result: aggregate})
 
-      :final_agregation_step ->
+      :final_aggregation_step ->
         new_opts = :sys.handle_debug(opts, &write_debug/3, __MODULE__, {:in, :final_aggregation_step})
 
         send(self(), :return_result)

```