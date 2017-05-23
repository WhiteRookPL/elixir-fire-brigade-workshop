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