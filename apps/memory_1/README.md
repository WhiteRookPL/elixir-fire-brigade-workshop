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