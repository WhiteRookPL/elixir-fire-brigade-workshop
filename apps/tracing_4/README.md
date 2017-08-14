# *TRACING_4*: Fixing bugs in `CurrencyConverter`

**Assignment name**: `TRACING_4`

**Topic**: *Tracing*

## Description

We have wrote simple client that will help us when doing various currencies conversion. It uses external *REST API* service so it caches responses in order to do not exceed calls limit. It also supports *BTC* cryptocurrency.

But it looks like it does not work properly. :(

## How to show it?

If we start our application in normal way:

```bash
~ $ iex -S mix
```

And invoke following commands we will see following lines:

```elixir
iex(...)> CurrencyConverter.pln2usd(1)
0.27984
iex(...)> CurrencyConverter.pln2eur(1)
0.27984
iex(...)> CurrencyConverter.eur2pln(1)
1.1868
iex(...)> CurrencyConverter.usd2pln(1)
0.0
iex(...)> CurrencyConverter.history() 
["2017-08-05T13:59:57Z: 1 PLN = 0.27984 USD",
 "2017-08-05T13:59:59Z: 1 PLN = 0.27984 EUR",
 "2017-08-05T14:00:01Z: 1 EUR = 1.1868 PLN",
 "2017-08-05T14:00:03Z: 1 USD = no_rate_for_such_currency PLN"] 
iex(...)> CurrencyConverter.cache()
[]
iex(...)> CurrencyConverter.rate("PLN", "BTC")
0.27984
iex(...)> CurrencyConverter.rate("BTC", "PLN")
3156.07
```

That's not what we expected!

## Detecting root cause

Let's trace first *API* calls:

```elixir
iex(...)> :recon_trace.calls({CurrencyConverter.API, :fetch, 2}, {10, 1000})
1
iex(...)> CurrencyConverter.pln2usd(1)
iex(...)> CurrencyConverter.pln2eur(1)
```

No sign of traces, are we getting those calls at all? `CurrencyConverter.API.fetch` has actually two different arities, let's try with other one.

```elixir
iex(...)> :recon_trace.clear()        
:ok
iex(...)> :recon_trace.calls({CurrencyConverter.API, :fetch, 1}, {10, 1000})
1
iex(...)> CurrencyConverter.pln2eur(1)                                      

16:8:56.384404 <0.229.0> 'Elixir.CurrencyConverter.API':fetch(<<"PLN">>)
0.27984
```

Gotcha! But what we're passing there? And from where it is called?

```elixir
iex(...)> :recon_trace.clear()        
:ok
iex(...)> :redbug.start(30_000, 10, ~C['Elixir.CurrencyConverter.API':fetch->return,stack])
{132, 2}
iex(42)> CurrencyConverter.pln2eur(1)
% 16:12:44 <0.229.0>('Elixir.CurrencyConverter.Cache')
% 'Elixir.CurrencyConverter.API':fetch(<<"PLN">>)
  proc_lib:init_p_do_apply/3 
  gen_server:handle_msg/5 
  gen_server:try_handle_call/4 

% 16:12:44 <0.229.0>('Elixir.CurrencyConverter.Cache')
% 'Elixir.CurrencyConverter.API':fetch(<<"PLN">>, <<"USD">>)
  proc_lib:init_p_do_apply/3 
  gen_server:handle_msg/5 
  gen_server:try_handle_call/4 
  'Elixir.CurrencyConverter.Cache':handle_call/3 
  'Elixir.CurrencyConverter.API':fetch/1 

% 16:12:44 <0.229.0>('Elixir.CurrencyConverter.Cache')
% 'Elixir.CurrencyConverter.API':fetch/2 -> {ok,{<<"PLN">>,<<"USD">>,0.27984}}
         
% 16:12:44 <0.229.0>('Elixir.CurrencyConverter.Cache')
% 'Elixir.CurrencyConverter.API':fetch/1 -> {ok,{<<"PLN">>,<<"USD">>,0.27984}}
0.27984
```

Aha! `'Elixir.CurrencyConverter.Cache':handle_call/3` - and of course there is a default there. :facepalm:

Let's fix it and check:

```elixir
iex(...)> CurrencyConverter.pln2eur(1)
0.23579
iex(...)> CurrencyConverter.pln2usd(1)
0.27984
```

Aww yiss! Is it everything? Not quite. We're calling *API* too many times. Data should be cached and refreshed periodically (every minute), but instead:

```elixir
iex(...)> CurrencyConverter.pln2usd(1)
0.27984
iex(...)> CurrencyConverter.pln2eur(1)
0.23579
iex(...)> CurrencyConverter.cache()   
[{"PLN", "USD"}, {"PLN", "EUR"}]

# Wait a minute...

iex(...)> CurrencyConverter.cache()
[]
```

Who does the refreshing? Let's look for calls to `'Elixir.CurrencyConverter.Cache':refresh/0`:

```elixir
iex(5)> :redbug.start(120_000, 10, ~C['Elixir.CurrencyConverter.Cache':refresh->return,stack])
{130, 1}
        
% 16:20:14 <0.230.0>('Elixir.CurrencyConverter.Converter')
% 'Elixir.CurrencyConverter.Cache':refresh()
  proc_lib:init_p_do_apply/3 
  gen_server:handle_msg/5 
  gen_server:try_dispatch/4 
        
% 16:20:14 <0.230.0>('Elixir.CurrencyConverter.Converter')
% 'Elixir.CurrencyConverter.Cache':refresh/0 -> ok
```

Aha! `'Elixir.CurrencyConverter.Converter'` calls this piece every minute. So let's check if we fetch the currencies:

```elixir
iex(...)> :redbug.start(120_000, 10, ~C['Elixir.CurrencyConverter.API':fetch->return,stack])

# ... cricket noises ...
# ... tumbleweeds are rolling ...
# ... no sign of those calls ...
```

Looking into implementation it became obvious that we're deleting objects from *ETS* **before** fetching new data. Quick fix and we're fetching new currencies, but are we updating values? 

It looks like we do not - let's confirm that:

```elixir
iex(...)> :redbug.start(120_000, 10, ~C[ets:insert(_,{{_,<<"BTC">>},_})->return,stack])
{127, 1}
iex(...)> CurrencyConverter.rate("PLN", "BTC")

% 16:32:28 <0.229.0>('Elixir.CurrencyConverter.Cache')
% ets:insert(196652, {{<<"PLN">>,<<"BTC">>},8.677e-5})
  proc_lib:init_p_do_apply/3 
  gen_server:handle_msg/5 
  gen_server:try_handle_call/4 
  'Elixir.CurrencyConverter.Cache':handle_call/3 

% 16:32:28 <0.229.0>('Elixir.CurrencyConverter.Cache')
% ets:insert/2 -> true
8.677e-5

# ... and again cricket noises only ...
```

Ah damn! There is no save call when refreshing currencies data. After a quick fix everything is perfectly fine and trace mentioned above confirms that we're updating rates.

## Fix

**Tag**: `FIX_FOR_TRACING_4`

```diff
diff --git a/apps/tracing_4/lib/cache.ex b/apps/tracing_4/lib/cache.ex
index e39d2a2..0706330 100644
--- a/apps/tracing_4/lib/cache.ex
+++ b/apps/tracing_4/lib/cache.ex
@@ -30,10 +30,13 @@ defmodule CurrencyConverter.Cache do
   end
 
   def handle_cast(:refresh, table) do
+    list_of_currencies = currencies(table)
+
     :ets.delete_all_objects(table)
 
-    currencies(table)
+    list_of_currencies
     |> Enum.map(fn({from, to}) -> CurrencyConverter.API.fetch(from, to) end)
+    |> Enum.each(fn({:ok, {from, to, rate}}) -> save(table, {from, to}, rate) end)
 
     {:noreply, table}
   end
@@ -49,8 +52,8 @@ defmodule CurrencyConverter.Cache do
         rate
 
       _ ->
-        case CurrencyConverter.API.fetch(from) do
-          {:ok, {from, to, rate}} ->
+        case CurrencyConverter.API.fetch(from, to) do
+          {:ok, {^from, ^to, rate}} ->
             save(table, {from, to}, rate)
             rate
```