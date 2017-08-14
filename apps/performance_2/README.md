# *PERFORMANCE_2*: Debugging slow REST API endpoints (`SpellCheckerAPI`)

**Assignment name**: `PERFORMANCE_2`

**Topic**: `:xprof`

## Description

We have prepared very simple *API* based on *Phoenix* that performs spell checking based on *Polish* dictionary. You can easily list words starting at a particular letter or even verify if provided word is a valid one.

However - the final endpoint is extremely slow.

## How to show it?

Let's open our application:

```bash
~ $ iex -S mix phx.server
```

And start `:xprof`:

```elixir
iex(...)> :xprof.start()
```

Then inside our browser, that is pointing at `http://localhost:7890`, we would like to trace the following:

```elixir
SpellCheckerAPI.Web.DictionaryProvider.words_for_letter/1
String.split(_, <<"\n">>)
```

And finally let's invoke our tests:

```bash
~ $ curl -s "http://localhost:4000/api/dictionary/Z" | jq
~ $ curl -s "http://localhost:4000/api/dictionary/X" | jq
~ $ curl -s "http://localhost:4000/api/dictionary/A" | jq
~ $ curl -s "http://localhost:4000/api/dictionary/L" | jq
```

You will see the problem in `:xprof` graphs or inside our console:

```elixir
iex(1)> [info] GET /api/dictionary/Z
[debug] Processing with SpellCheckerAPI.Web.DictionaryController.words_for_letter/2
  Parameters: %{"letter" => "Z"}
  Pipelines: [:api]
[info] Sent 200 in 4163ms
[info] GET /api/dictionary/X
[debug] Processing with SpellCheckerAPI.Web.DictionaryController.words_for_letter/2
  Parameters: %{"letter" => "X"}
  Pipelines: [:api]
[info] Sent 200 in 3685ms
[info] GET /api/dictionary/A
[debug] Processing with SpellCheckerAPI.Web.DictionaryController.words_for_letter/2
  Parameters: %{"letter" => "A"}
  Pipelines: [:api]
[info] Sent 200 in 3849ms
[info] GET /api/dictionary/L
[debug] Processing with SpellCheckerAPI.Web.DictionaryController.words_for_letter/2
  Parameters: %{"letter" => "L"}
  Pipelines: [:api]
[info] Sent 200 in 4044ms
```

It turns out that it we're spending a lot of time in simple splitting - even if the input is huge, it shouldn't take so long to split it.

## Detecting root cause

Let's take a different approach and let's use `String.splitter/2` available in standard library. **Woah!** Result is unbelievable. Should we always use streams then?

It turns out that explanation for that issue is not entirely simple and easy. Streaming could be faster for higher inputs, but it shouldn't be faster by an order of magnitude. 

It turns out that internally that there is performance degradation when it comes to `:binary.split/3` and `:binary.matches/2,3` because of some internal *BIF* implementation, details can be found here:

- https://github.com/elixir-lang/elixir/issues/6148
- https://github.com/erlang/otp/pull/1480

It will not land in `Erlang 20.0` however. :confused:

Additional improvement to our solution is caching based on *ETS* table, when we save the parsed representation.

## Fix

**Tag**: `FIX_FOR_PERFORMANCE_2`

```diff
diff --git a/apps/performance_2/lib/spell_checker_api/application.ex b/apps/performance_2/lib/spell_checker_api/application.ex
index 1a643be..4d4c0f7 100644
--- a/apps/performance_2/lib/spell_checker_api/application.ex
+++ b/apps/performance_2/lib/spell_checker_api/application.ex
@@ -8,7 +8,25 @@ defmodule SpellCheckerAPI.Application do
       supervisor(SpellCheckerAPI.Web.Endpoint, [])
     ]
 
+    :ets.new(SpellCheckerAPI.Cache, [:public, :set, :named_table, {:read_concurrency, true}])
+    cache_words()
+
     opts = [ strategy: :one_for_one, name: SpellCheckerAPI.Supervisor ]
     Supervisor.start_link(children, opts)
   end
+
+  defp cache_words() do
+    {:ok, content} = File.read(priv("pl.dict"))
+
+    words =
+      content
+      |> String.splitter("\n")
+      |> Enum.to_list()
+
+    :ets.insert(SpellCheckerAPI.Cache, {:words, words})
+  end
+
+  defp priv(filename) do
+    Path.join(:code.priv_dir(:spell_checker_api), filename)
+  end
 end
\ No newline at end of file
diff --git a/apps/performance_2/lib/spell_checker_api/web/logic/dictionary_provider.ex b/apps/performance_2/lib/spell_checker_api/web/logic/dictionary_provider.ex
index 18087c5..d8f81f1 100644
--- a/apps/performance_2/lib/spell_checker_api/web/logic/dictionary_provider.ex
+++ b/apps/performance_2/lib/spell_checker_api/web/logic/dictionary_provider.ex
@@ -1,9 +1,8 @@
 defmodule SpellCheckerAPI.Web.DictionaryProvider do
   def words_for_letter(letter) do
-    {:ok, content} = File.read(priv("pl.dict"))
+    [ {:words, content} ] = :ets.lookup(SpellCheckerAPI.Cache, :words)
 
     content
-    |> String.split("\n")
     |> Enum.filter(fn(line) -> String.first(line) == letter end)
     |> Enum.map(&String.downcase/1)
     |> Enum.map(fn(line) -> String.split(line, " ") end)
@@ -14,8 +13,4 @@ defmodule SpellCheckerAPI.Web.DictionaryProvider do
     words_for_letter(String.first(word))
     |> Enum.member?(word)
   end
-
-  defp priv(filename) do
-    Path.join(:code.priv_dir(:spell_checker_api), filename)
-  end
 end
\ No newline at end of file
```