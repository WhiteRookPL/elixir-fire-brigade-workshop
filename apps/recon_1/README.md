# *RECON_1*: Debugging `RedisClone` finding a reason for resource leaks

**Assignment name**: `RECON_1`

**Topic**: *Resource Leak*

## Description

Something is going wrong when we're accessing our `RedisClone` application over *TCP connection*. Like we would leaking connections.

## How to show it?

Open the `iex` session:

```bash
~ $ iex -S mix
```

And invoke a lot of commands:

```elixir
iex(...)1> for i <- 0 .. 10_000, do: RedisClone.Client.command("PUT a_#{i} #{i}")
```

And wait for something like this:

```elixir
** (MatchError) no match of right hand side value: {:error, :emfile}
    (recon_1) lib/client.ex:11: RedisClone.Client.open/1
```