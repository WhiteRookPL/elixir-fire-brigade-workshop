# *MEMORY_2*: Binary problems again (`Audiophile`)

**Assignment name**: `MEMORY_2`

**Topic**: *Ports* + *Memory Management* (and `:erlang.system_monitor/2`)

## Description

We have modified slightly our previous application called `Audiophile` to sum up time per artist for our music collection stored in `mp3` files. For extracting duration we will use another binary available in our *OS* called `mp3info` - as *Erlang* has a facility for communicating with external programs called *Ports*. 

## How to show it?

If we start our application in normal way:

```bash
~ $ iex --name main@127.0.0.1 --cookie test -S mix
```

And invoke following commands we will see following results:

```elixir
iex(...)> :observer.start()
iex(...)> Audiophile.scan("/your/dir/with/a/even/small/amount/of/mp3")
:scanned
iex(...)> Audiophile.statistics()
%{artists: []}
```

It runs slowly. Much slower than last time - what happened? 

## Detecting root cause

 Let's attach remote shell and check:

```bash
iex --remsh main@127.0.0.1 --name remsh@127.0.0.1 --cookie test -S mix
```

We'd like to check amount ports during execution:

```elixir
iex(remsh@127.0.0.1)> :recon.port_types()
[{'efile', 6}, {'tcp_inet', 3}, {'2/2', 1}, {'forker', 1},
 {'mp3info -p "%S" "/path/to/audio.mp3"', 1}, {'tty_sl -c -e', 1}]
```

Only one running. Let's trace execution time:

```elixir
iex(remsh@127.0.0.1)> :redbug.start(~C['Elixir.Audiophile.FileParser':extract_duration->return], [time: 120_000, msgs: 20, print_msec: true])
{136, 1}
                       
% 23:17:06.411 <0.214.0>('Elixir.Audiophile.Scanner')
% 'Elixir.Audiophile.FileParser':extract_duration(<<"/path/to/file.mp3">>)
                       
% 23:17:11.416 <0.214.0>('Elixir.Audiophile.Scanner')
% 'Elixir.Audiophile.FileParser':extract_duration/1 -> {error,
                                                        port_not_responding}
```

Hm, we're waiting 5 seconds per file? After looking into code and documentation cause is visible immediately - when using `Port.close/1` we will not receive `{#Port<...>, :closed}` message to actual process. After removing `receive` clauses we can go further.

*Sigh*, not everything works properly now - we're having problems with memory usage again. Let's investigate what is the cause:

```elixir
iex(...)> :recon.proc_count(:binary_memory, 3)
[{#PID<0.219.0>, 1678568260,
  [Audiophile.Scanner, {:current_function, {:gen_server, :loop, 6}},
   {:initial_call, {:proc_lib, :init_p, 5}}]},
 ...
```

Once again it is `Audiophile.Scanner`. Let's check what this time causing the trouble: 

```elixir
iex(...)> :recon.info(pid(0,219,0))
[meta: [registered_name: Audiophile.Scanner,
  dictionary: ["$initial_call": {Audiophile.Scanner, :init, 1},
   "$ancestors": [#PID<0.217.0>, #PID<0.216.0>]], group_leader: #PID<0.215.0>,
  status: :waiting],
 signals: [links: [#PID<0.217.0>], monitors: [], monitored_by: [],
  trap_exit: false],
 location: [initial_call: {:proc_lib, :init_p, 5},
  current_stacktrace: [{:gen_server, :loop, 6,
    [file: 'gen_server.erl', line: 368]},
   {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]],
 memory_used: [memory: 163504, message_queue_len: 0, heap_size: 2586,
  total_heap_size: 20317,
  garbage_collection: [max_heap_size: %{error_logger: true, kill: true,
     size: 0}, min_bin_vheap_size: 46422, min_heap_size: 233,
   fullsweep_after: 65535, minor_gcs: 1]], work: [reductions: 159769]]
iex(...)> :erlang.process_info(pid(0,219,0))
[registered_name: Audiophile.Scanner, current_function: {:gen_server, :loop, 6},
 initial_call: {:proc_lib, :init_p, 5}, status: :waiting, message_queue_len: 0,
 messages: [], links: [#PID<0.217.0>],
 dictionary: ["$initial_call": {Audiophile.Scanner, :init, 1},
  "$ancestors": [#PID<0.217.0>, #PID<0.216.0>]], trap_exit: false,
 error_handler: :error_handler, priority: :normal, group_leader: #PID<0.215.0>,
 total_heap_size: 20317, heap_size: 2586, stack_size: 9, reductions: 159769,
 garbage_collection: [max_heap_size: %{error_logger: true, kill: true, size: 0},
  min_bin_vheap_size: 46422, min_heap_size: 233, fullsweep_after: 65535,
  minor_gcs: 1], suspending: []]
iex(...)> :sys.get_state(pid(0,219,0))      
[{"/path/to/mp3/files",
  [<<84, 65, 71, 76, 101, 115, 122, 101, 107, 32, 175, 117, 107, 111, 119, 115,
     107, 105, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 67, 111, 109, 97, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, ...>>,
 ...
```

**Aha!** So we are accumulating state in that process. Quick look into code and we see that we're passing around binary fragment of `ID3` tag. which holds the whole file again. As we're not using it inside *history*, we can reorganize the code - after that everything works smoothly.

In order to show `:long_gc` pause we would like to cheat a little bit. There is a `cleanup/0` function inside `Audiophile.Scanner` that will be able to track `:erlang.system_monitor/2` call:

```elixir
iex(...)> :erlang.system_monitor(self(), [{:long_gc, 100}])
:undefined
iex(...)> Audiophile.scan("/your/dir/with/a/even/small/amount/of/mp3")
:scanned
iex(...)> flush()
{:monitor, #PID<0.210.0>, :long_gc, ... }
:ok
iex(...)> Process.whereis(Audiophile.Scanner)
#PID<0.210.0>
```

Why this process has `:long_gc` pause? Well, as I said, we cheated:

```elixir
  defp cleanup() do
    :erts_debug.set_internal_state(:available_internal_state, true)
    :erts_debug.set_internal_state(:test_long_gc_sleep, 100)

    :erlang.garbage_collect()

    :erts_debug.set_internal_state(:test_long_gc_sleep, 0)
    :erts_debug.set_internal_state(:available_internal_state, false)
  end
```

This adds artificial *GC* pause, it adds print into the console and it is not a real *GC* pause. That is the most reliable way of introducing *GC* pause. After removing that piece, we can proceed with our tests and confirm that everything is okay from now on.

## Fix

**Tag**: `FIX_FOR_MEMORY_2`

```diff
diff --git a/apps/memory_2/lib/file_parser.ex b/apps/memory_2/lib/file_parser.ex
index fa615a3..6a57088 100644
--- a/apps/memory_2/lib/file_parser.ex
+++ b/apps/memory_2/lib/file_parser.ex
@@ -18,7 +18,7 @@ defmodule Audiophile.FileParser do
              _track    :: binary-size(1),
              _genre    :: binary-size(1) >> = id3_tag
 
-          {:ok, %{ artist: pretty_print(artist), id3: id3_tag }}
+          {:ok, %{ artist: pretty_print(artist) }}
         catch
           _ -> {:error, {filename, :invalid_id3_tag}}
         end
@@ -35,24 +35,14 @@ defmodule Audiophile.FileParser do
       {^port, {:data, seconds}} ->
         Port.close(port)
 
-        receive do
-          {^port, :closed} ->
-            case Integer.parse(seconds) do
-              {seconds, _} -> {:ok, seconds}
-              :error       -> {:error, :duration_not_available}
-            end
-        after
-          @default_port_timeout -> {:error, :port_not_responding}
+        case Integer.parse(seconds) do
+          {seconds, _} -> {:ok, seconds}
+          :error       -> {:error, :duration_not_available}
         end
     after
       @default_port_timeout ->
         Port.close(port)
-
-        receive do
-          {^port, :closed} -> {:error, :port_not_responding}
-        after
-          @default_port_timeout -> {:error, :port_not_responding}
-        end
+        {:error, :port_not_responding}
     end
   end
 
diff --git a/apps/memory_2/lib/scanner.ex b/apps/memory_2/lib/scanner.ex
index f998c7f..a02e52c 100644
--- a/apps/memory_2/lib/scanner.ex
+++ b/apps/memory_2/lib/scanner.ex
@@ -32,7 +32,7 @@ defmodule Audiophile.Scanner do
   def handle_call({:scan, path}, _from, history) do
     files = Path.wildcard("#{path}/**/*.mp3")
 
-    processed_tags =
+    processed_files =
       files
       |> Flow.from_enumerable(stages: 8, max_demand: 1)
       |> Flow.map(fn(filename) -> {filename, Audiophile.FileParser.extract_duration(filename)} end)
@@ -43,14 +43,11 @@ defmodule Audiophile.Scanner do
       |> Flow.map(&store_and_collect_id3_tag/1)
       |> Enum.to_list()
 
-    cleanup()
-
-    {:reply, :scanned, [ {path, length(processed_tags)} | history ]}
+    {:reply, :scanned, [ {path, length(processed_files)} | history ]}
   end
 
-  defp store_and_collect_id3_tag({{:ok, %{ :artist => artist, :id3 => id3 }}, {:ok, time}}) do
+  defp store_and_collect_id3_tag({{:ok, %{ :artist => artist }}, {:ok, time}}) do
     Audiophile.Storage.update(artist, time)
-    id3
   end
 
   defp maybe_print_error({{:ok, _}, _} = value), do: value
@@ -61,14 +58,4 @@ defmodule Audiophile.Scanner do
 
   defp file_description(1), do: "file"
   defp file_description(_), do: "files"
-
-  defp cleanup() do
-    :erts_debug.set_internal_state(:available_internal_state, true)
-    :erts_debug.set_internal_state(:test_long_gc_sleep, 100)
-
-    :erlang.garbage_collect()
-
-    :erts_debug.set_internal_state(:test_long_gc_sleep, 0)
-    :erts_debug.set_internal_state(:available_internal_state, false)
-  end
 end
\ No newline at end of file
```