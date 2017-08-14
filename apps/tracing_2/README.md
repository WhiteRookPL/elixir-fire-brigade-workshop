# *TRACING_2*: Debugging failing test with tracing (`KV.RegistryTest`).

**Assignment name**: `TRACING_2`

**Topic**: `:sys` + *Tracing*

## Description

Probably you couldn't see that immediately, but there is one test failing in non deterministic way. Let's tackle this problem!

## How to show it?

1. Test isolation will not work, at least not in ideal way - test still fails in non deterministic way.
2. For me it failed with following `seed` - still in non-deterministic way:
   ```bash
   ~ $ cd apps/tracing_2
   ~ $ mix test test/kv_registry_test.exs:41 --seed 971306
   ```
3. The way to finally force it:
   ```bash
   ~ $ cd apps/tracing_2
   ~ $ while true; do mix test test/kv_registry_test.exs:41 --seed 971306; if [[ $? -ne 0 ]]; then break; fi; done
   ```

## Detecting root cause

1. From the assertion and test context we can see that we try to get bucket after deleting it, and it still exists.
2. Let's look into code - `apps/tracing_2/lib/kv/registry.ex:84` - delete does `Agent.stop` and then we wait for asynchronous message in `handle_info` from monitored process.
3. What if we do lookup earlier than message arrives and deletes its from `:ets`? We have our error.
4. Let's confirm it by those commands inserted after creation of the bucket in the test:
   ```elixir
    :dbg.tracer()
    :dbg.p(:all, :c)
    :sys.trace(registry, true)
    :dbg.tp(:'Elixir.KV.Registry', :lookup, :c)
   ```
5. Confirmed!
  - Also look at the fun fact - we cannot reproduce it earlier (it was hard) entering just `:sys.trace(registry, true)` immediately invokes the error.
    - Why? Reductions!
      - Our tests passed because our `registry` process was not scheduled out from current scheduler and received `:'DOWN'` message in the same turn that it can handle it immediately.
      - Enabling traces causes additional operations to be invoked (e.g. printing, `handle_debug/4`) and we got scheduled out, message arrived waited in the mailbox.
      - And then test got scheduled in and checked `:ets`.
      - We will talk about that mechanism later in details.

## Fix

**Tag**: `FIX_FOR_TRACING_2`

```diff
diff --git a/apps/tracing_2/test/kv_registry_test.exs b/apps/tracing_2/test/kv_registry_test.exs
index b6e13f1..9ebc1cf 100644
--- a/apps/tracing_2/test/kv_registry_test.exs
+++ b/apps/tracing_2/test/kv_registry_test.exs
@@ -42,6 +42,9 @@ defmodule KV.RegistryTest do
     KV.Registry.create(registry, "shopping")

     assert KV.Registry.delete(registry, "shopping") == :bucket_deleted
+
+    # Do a sync to ensure the registry processed the down message
+    _ = KV.Registry.create(registry, "bogus")
     assert KV.Registry.lookup(registry, "shopping") == :error
   end
```

Yes, fix is as simple as sending another operation, causing reductions to be filled in, rescheduling everything and "serializing" processing of messages.
