# *MEMORY_1*: Memory leaks in `Audiophile` application

**Assignment name**: `MEMORY_1`

**Topic**: *Memory Management*

## Description

Because I am a huge fan of various music (yes, I have eclectic taste :wink:) I have built small application that will collect data from my music collection. But I was lousy when when it comes to memory management.

Could you help me fixing that?

## How to show it?

If we start our application in normal way:

```bash
~ $ iex -S mix
```

And invoke following commands we will see following results:

```elixir
iex(...)> :observer.start()
iex(...)> Audiophile.scan("/your/dir/with/a/lot/of/mp3")
:scanned
iex(...)> Audiophile.statistics()
%{artists: [...], genres: [...], years: [...]}
```

What did just happen with memory? It grows in an rapid way, it almost hit total *RAM* limit on my machine for bigger directories - it is visible when you have big directory and scanning takes a lot of time - during that memory usage is skyrocketing to the top, after it drops a little bit, but still not to reasonable limit. Why it eats memory like *Chrome* or *Slack* desktop application? :wink:

## Detecting root cause

Our application harvests `ID3` tags from `MP3` files and based on that extracts data for our statistics. As you may notice in the file `file_parser.ex` it matches the binary parts of the file and pass them around.

If you will try to enforce typical garbage collection, it will not help - but `:recon.bin_leak/1` helps and shows the culprit immediately:

```elixir
iex(...)> :erlang.garbage_collect()
iex(...)> :recon.bin_leak(5)
[{#PID<0.219.0>, -72,
  [Audiophile.Scanner, {:current_function, {:gen_server, :loop, 6}},
   {:initial_call, {:proc_lib, :init_p, 5}}]},
 {#PID<0.45.0>, -33,
  [:file_server_2, {:current_function, {:gen_server, :loop, 6}},
   {:initial_call, {:proc_lib, :init_p, 5}}]},
 {#PID<0.51.0>, -28,
  [current_function: {:group, :server_loop, 3},
   initial_call: {:group, :server, 3}]},
 {#PID<0.226.0>, -26,
  [current_function: {:wx_object, :loop, 6},
   initial_call: {:proc_lib, :init_p, 5}]},
 {#PID<0.4.0>, -11,
  [:erl_prim_loader, {:current_function, {:erl_prim_loader, :loop, 3}},
   {:initial_call, {:erlang, :apply, 2}}]}]
```

Even if it drops after that, we're still holding that memory somewhere. We can proceed with simple method:

```elixir
iex(...)> :recon_alloc.set_unit(:gigabyte)
:undefined
iex(...)> :recon_alloc.memory(:used)      
0.6375794187188148
iex(...)> :recon_alloc.memory(:allocated) 
0.7018547058105469
```

Or with more advanced methods (it is more visible on clear session):

```elixir
iex(...)> :recon_alloc.allocators()
{ ... huge pile of unreadable data ... }
iex(...)> :recon_alloc.snapshot()
:undefined
iex(...)> Audiophile.scan("/your/dir/with/a/lot/of/mp3")  
:scanned
iex(...)> :recon_alloc.snapshot() 
{ ... smaller pile of data, still unreadable ... }
```

If you know how to read that pile of data returned from those function you are pretty sure what is the case. But understanding all pieces of those reports is beyond the scope of this workshop (you may spend entire workshop on memory management on *BEAM*). But there is other way around. :wink:

We're pretty sure what held that memory before `:recon.bin_leak/1` - `Audiophile.Scanner` after forced *GC* released the biggest amount of binary references. Still we have a lot of binaries in memory anyway. Let's check processes and *ETS*:

```elixir
iex(...)> :recon.info(Process.whereis(Audiophile.Scanner))
[meta: [registered_name: Audiophile.Scanner,
  dictionary: ["$initial_call": {Audiophile.Scanner, :init, 1},
   "$ancestors": [#PID<0.206.0>, #PID<0.205.0>]], group_leader: #PID<0.204.0>,
  status: :waiting],
 signals: [links: [#PID<0.206.0>], monitors: [], monitored_by: [],
  trap_exit: false],
 location: [initial_call: {:proc_lib, :init_p, 5},
  current_stacktrace: [{:gen_server, :loop, 6,
    [file: 'gen_server.erl', line: 368]},
   {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]],
 memory_used: [memory: 2832, message_queue_len: 0, heap_size: 233,
  total_heap_size: 233,
  garbage_collection: [max_heap_size: %{error_logger: true, kill: true,
     size: 0}, min_bin_vheap_size: 46422, min_heap_size: 233,
   fullsweep_after: 65535, minor_gcs: 0]], work: [reductions: 367851]]
iex(...)> :recon.info(Process.whereis(Audiophile.Storage))
[meta: [registered_name: Audiophile.Storage,
  dictionary: ["$initial_call": {Audiophile.Storage, :init, 1},
   "$ancestors": [#PID<0.206.0>, #PID<0.205.0>]], group_leader: #PID<0.204.0>,
  status: :waiting],
 signals: [links: [#PID<0.206.0>], monitors: [], monitored_by: [],
  trap_exit: false],
 location: [initial_call: {:proc_lib, :init_p, 5},
  current_stacktrace: [{:gen_server, :loop, 6,
    [file: 'gen_server.erl', line: 368]},
   {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 247]}]],
 memory_used: [memory: 2832, message_queue_len: 0, heap_size: 233,
  total_heap_size: 233,
  garbage_collection: [max_heap_size: %{error_logger: true, kill: true,
     size: 0}, min_bin_vheap_size: 46422, min_heap_size: 233,
   fullsweep_after: 65535, minor_gcs: 0]], work: [reductions: 23850]]
iex(...)> :erlang.memory()
[total: 532083272, processes: 13345560, processes_used: 13343448,
 system: 518737712, atom: 621465, atom_used: 614737, binary: 491474736,
 code: 14474058, ets: 1352944]
iex(...)> :ets.i()        
 id              name              type  size   mem      owner
 ----------------------------------------------------------------------------
 127017          genres            set   31     624      'Elixir.Audiophile.Storage'
 131114          artists           set   105    1663     'Elixir.Audiophile.Storage'
 135211          year              set   77     1299     'Elixir.Audiophile.Storage'
iex(...)> :recon.proc_count(:memory, 3)
[{#PID<0.51.0>, 2917936,
  [current_function: {:group, :server_loop, 3},
   initial_call: {:group, :server, 3}]},
 {#PID<0.36.0>, 2917752,
  [:code_server, {:current_function, {:code_server, :loop, 1}},
   {:initial_call, {:erlang, :apply, 2}}]},
 {#PID<0.218.0>, 1804264,
  [current_function: {:wx_object, :loop, 6},
   initial_call: {:proc_lib, :init_p, 5}]}]
```

*Sigh*. Nothing really stands out. Let's check the last thing, on fresh session:

```elixir
iex(6)> :recon.proc_count(:binary_memory, 3)                     
[{#PID<0.208.0>, 2745599661,
  [Audiophile.Scanner, {:current_function, {:gen_server, :loop, 6}},
   {:initial_call, {:proc_lib, :init_p, 5}}]},
 {#PID<0.207.0>, 94343017,
  [Audiophile.Storage, {:current_function, {:gen_server, :loop, 6}},
   {:initial_call, {:proc_lib, :init_p, 5}}]},
 {#PID<0.45.0>, 2929182,
  [:file_server_2, {:current_function, {:gen_server, :loop, 6}},
   {:initial_call, {:proc_lib, :init_p, 5}}]}]
```

**Aha!** We knew about `Audiophile.Scanner`, but `Audiophile.Storage` is a new thing. Why it behaves like that?

The reason for this whole abomination is simple: we're carving out smaller binary from a bigger one and we're passing it around. For `Audiophile.Scanner` we're passing it around and increase `refc` - so this one can be *garbage collected* after. In case of `Audiophile.Storage` we're passing it around and save it to *ETS*. It is hard to release that memory as is it still hold by smaller binary stored *ETS* - and memory of bigger binary does not belong to *ETS*. From the other hand *ETS* can copy that sub-binary as it might be suboptimal. It was visible in `:recon_alloc.allocators/0` or when doing `:recon.snapshot/0` - if you know how it works and how to read that report. I strongly recommend *Erlang in Anger* (by *Fred Hebert*) and *The Beam Book* (by *Erik Stenman*) if you would like to learn that.

After fixing this and testing it, we're using significantly smaller amount of memory during processing and after.

## Fix

**Tag**: `FIX_FOR_MEMORY_1`

```diff
diff --git a/apps/memory_1/lib/file_parser.ex b/apps/memory_1/lib/file_parser.ex
index 6ec7499..d9bab8e 100644
--- a/apps/memory_1/lib/file_parser.ex
+++ b/apps/memory_1/lib/file_parser.ex
@@ -16,7 +16,7 @@ defmodule Audiophile.FileParser do
              _track    :: binary-size(1),
              genre     :: binary-size(1) >> = id3_tag
 
-          {:ok, %{ genre: genre_id_to_name(genre), artist: artist, year: year }}
+          {:ok, %{ genre: genre_id_to_name(genre), artist: pretty_print(artist), year: pretty_print(year) }}
         catch
           _ -> {:error, {filename, :invalid_id3_tag}}
         end
@@ -26,6 +26,14 @@ defmodule Audiophile.FileParser do
     end
   end
 
+  defp pretty_print(raw) do
+    String.codepoints(raw)
+    |> Enum.filter(&String.valid?/1)
+    |> Enum.filter(fn(codepoint) -> codepoint != <<0>> end)
+    |> Enum.join("")
+    |> String.trim()
+  end
+
   defp genre_id_to_name(<<0>>), do: "Blues"
   defp genre_id_to_name(<<1>>), do: "Classic Rock"
   defp genre_id_to_name(<<2>>), do: "Country"
diff --git a/apps/memory_1/lib/storage.ex b/apps/memory_1/lib/storage.ex
index 070e47b..f25dce3 100644
--- a/apps/memory_1/lib/storage.ex
+++ b/apps/memory_1/lib/storage.ex
@@ -50,18 +50,9 @@ defmodule Audiophile.Storage do
 
   defp get_all_and_sort(table) do
     :ets.tab2list(table)
-    |> Enum.map(fn({key, value}) -> {pretty_print(key), value} end)
     |> Enum.sort(fn({_, value1}, {_, value2}) -> value1 >= value2 end)
   end
 
-  defp pretty_print(raw) do
-    String.codepoints(raw)
-    |> Enum.filter(&String.valid?/1)
-    |> Enum.filter(fn(codepoint) -> codepoint != <<0>> end)
-    |> Enum.join("")
-    |> String.trim()
-  end
-
   defp update_counter(table, key) do
     :ets.update_counter(table, key, 1, {key, 0})
   end
```