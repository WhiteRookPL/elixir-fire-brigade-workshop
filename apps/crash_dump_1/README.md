# *CRASH_DUMP_1*: Erlang VM crash caused by limit for memory or atom table

**Assignment name**: `CRASH_DUMP_1`

**Topic**: *Erlang Crash Dump*

## Description

There are 2 places in that assignment to fix:

1. We are allocating a lot of memory, due to programmers bug.
2. We are creating atoms based on user input. 
 
Let's look why both cases are a bad idea.

## How to show it?

```bash
~ $ iex -S mix
```

And after a while our *Erlang VM* will be killed and will leave a crash dump. After we will fix this issue and start over again, we will see another crash dump - this time caused by different issue.

## Detecting root cause

```bash
~ $ ./deps/recon/scripts/erl_crashdump_analyzer.sh erl_crash.dump
~ $ awk -v threshold=10000 -f ./deps/recon/scripts/queue_fun.awk erl_crash.dump
```

In first case we have infinite recursion that allocates a lot on heap, in second case - calls to `String.to_atom/1`.

## Fix

**Tag**: `FIX_FOR_CRASH_DUMP_1`

```diff
diff --git a/apps/crash_dump_1/lib/atom_eater.ex b/apps/crash_dump_1/lib/atom_eater.ex
index 30fc9ac..a513343 100644
--- a/apps/crash_dump_1/lib/atom_eater.ex
+++ b/apps/crash_dump_1/lib/atom_eater.ex
@@ -14,8 +14,7 @@ defmodule Crasher.AtomEater do
   end
 
   def handle_info(:timeout, {delay, acc}) do
-    postfix = :base64.encode(:crypto.strong_rand_bytes(20))
-    new_atom = String.to_atom("new_atom_#{postfix}")
+    new_atom = String.to_existing_atom("new_atom")
 
     :erlang.send_after(delay, self(), :timeout)
 
diff --git a/apps/crash_dump_1/lib/memory_eater.ex b/apps/crash_dump_1/lib/memory_eater.ex
index a78de1e..d3a48e3 100644
--- a/apps/crash_dump_1/lib/memory_eater.ex
+++ b/apps/crash_dump_1/lib/memory_eater.ex
@@ -22,5 +22,5 @@ defmodule Crasher.MemoryEater do
   end
 
   defp infinite_reverse([], result), do: result
-  defp infinite_reverse([ head | _ ] = input, acc), do: infinite_reverse(input, [ head | acc ])
+  defp infinite_reverse([ head | tail ], acc), do: infinite_reverse(tail, [ head | acc ])
 end
\ No newline at end of file
```
