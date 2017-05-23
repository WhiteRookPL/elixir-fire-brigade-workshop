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