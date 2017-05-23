# *OTP_2*: Debugging `:proc_lib` (`Chatterboxes`)

**Assignment name**: `OTP_2`

**Topic**: `:proc_lib` and *special processes*.

## Description

We've created application that elements are built on top of special processes (`:proc_lib`). And something is not working properly there. Let's debug this!

## How to show it?

```bash
~ $ iex -S mix
```

Wait for a bit and execute following command:

```elixir
iex(...)> Chatterboxes.Statistics.get_result()
%{}
```

That's not right - we should aggregate periodically elements that are coming from *a few blabbers*. Let's investigate which items are flowing through the system.