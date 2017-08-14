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

## Detecting root cause

1. Let's check state of the application with available tools:
  - `iex(...)1> :recon.tcp()` - a lot of ports opened, add `length(:recon.tcp())` to it in order calculate those.
  - `iex(...)1> :recon.port_types()`
  - `iex(...)1> [a, b] = Enum.take(:recon.tcp(), -2)`
  - `iex(...)2> :recon.port_info(a)`
    - It shows one process in links.
      - `iex(...)1> :recon.info(p, i, d)`
        - It is `IEx` shell!
          - So client does not close the connection.

## Fix

**Tag**: `FIX_FOR_RECON_1`

```diff
diff --git a/apps/recon_1/lib/client.ex b/apps/recon_1/lib/client.ex
index 4c068f7..3dac19f 100644
--- a/apps/recon_1/lib/client.ex
+++ b/apps/recon_1/lib/client.ex
@@ -1,8 +1,13 @@
 defmodule RedisClone.Client do
   def command(string) do
     socket = open(6379)
+
     send_data(socket, [string,  ?\r, ?\n])
-    String.trim(recv(socket))
+    response = String.trim(recv(socket))
+
+    :gen_tcp.close(socket)
+
+    response
   end
 
   # Private API.
```

