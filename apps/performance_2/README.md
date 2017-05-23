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