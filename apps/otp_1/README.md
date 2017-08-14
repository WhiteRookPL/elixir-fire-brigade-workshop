# *OTP_1*: Curious Case of Dodos Extinction 

**Assignment name**: `OTP_1`

**Topic**: `:reached_max_restart_intensity`

## Description

## How to show it?

```bash
~ $ iex -S mix
```

And execute following commands:

```elixir
iex(...)> World.start()
{:ok, []}
iex(...)> World.add_dodos(10)
:ok
iex(...)> World.add_cockroaches(10)
:ok
iex(...)> World.dodos()
[#PID<0.279.0>, #PID<0.280.0>, #PID<0.281.0>, #PID<0.272.0>, #PID<0.273.0>,
 #PID<0.274.0>, #PID<0.275.0>, #PID<0.276.0>, #PID<0.277.0>, #PID<0.278.0>]
iex(...)> World.cockroaches()
[#PID<0.283.0>, #PID<0.284.0>, #PID<0.285.0>, #PID<0.286.0>, #PID<0.287.0>,
 #PID<0.288.0>, #PID<0.289.0>, #PID<0.290.0>, #PID<0.291.0>, #PID<0.292.0>]
iex(...)> World.kill_cockroaches()
[true, true, true, true, true, true, true, true, true, true]
iex(...)> World.kill_dodos()
[true, true, true, true, true, true, true, true, true, true]
iex(...)> World.cockroaches()
[]
iex(...)> World.dodos()
** (exit) exited in: GenServer.call(World.Dodos.Supervisor, :which_children, :infinity)
    ** (EXIT) no process: the process is not alive or there's no process currently associated with the given name, possibly because its application isn't started
    (elixir) lib/gen_server.ex:766: GenServer.call/3
    (world) lib/world.ex:51: World.all/1
iex(...)> World.add_dodos(10)
** (exit) exited in: GenServer.call(World.Dodos.Supervisor, {:start_child, []}, :infinity)
    ** (EXIT) no process: the process is not alive or there's no process currently associated with the given name, possibly because its application isn't started
    (elixir) lib/gen_server.ex:766: GenServer.call/3
    (world) lib/world.ex:46: World.add_animals/2
```

Why one supervisor is restarted properly and it is much more persistent (*Cockroaches*) and one extinct and do not want start again (*Dodos*)?

## Detecting root cause

After enabling *SASL* (remember about the order - you need to enable after `:logger`, otherwise it will swallow reports) you will see the reason why one supervisor is restarted properly and one do not:

```elixir
=SUPERVISOR REPORT==== 31-Jul-2017::21:00:10 ===
     Supervisor: {local,'Elixir.World.Dodos.Supervisor'}
     Context:    shutdown
     Reason:     reached_max_restart_intensity
     Offender:   [{pid,<0.272.0>},
                  {id,'Elixir.World.Dodos.Supervisor'},
                  {mfargs,
                      {'Elixir.World.Animal',start_link,
                          ['Elixir.World.Dodos.Supervisor']}},
                  {restart_type,permanent},
                  {shutdown,5000},
                  {child_type,worker}]
```

## Fix

Don't use transient supervisors if you want your parent supervisor to restart them in case of `:max_restart_intensity`.

**Tag**: `FIX_FOR_OTP_1`

```diff
diff --git a/apps/otp_1/lib/supervisor.ex b/apps/otp_1/lib/supervisor.ex
index a6bbbb3..c22f8ba 100644
--- a/apps/otp_1/lib/supervisor.ex
+++ b/apps/otp_1/lib/supervisor.ex
@@ -7,7 +7,7 @@ defmodule World.Supervisor do
 
   def init(:ok) do
     children = [
-      supervisor(World.Animals.Supervisor, [World.Dodos.Supervisor], id: World.Dodos.Supervisor, restart: :transient),
+      supervisor(World.Animals.Supervisor, [World.Dodos.Supervisor], id: World.Dodos.Supervisor, restart: :permanent),
       supervisor(World.Animals.Supervisor, [World.Cockroaches.Supervisor], id: World.Cockroaches.Supervisor, restart: :permanent)
     ]
 
diff --git a/apps/otp_1/mix.exs b/apps/otp_1/mix.exs
index 15ed2a6..92320a7 100644
--- a/apps/otp_1/mix.exs
+++ b/apps/otp_1/mix.exs
@@ -23,7 +23,7 @@ defmodule World.Mixfile do
   end
 
   defp apps(env) when env == :test, do: [ :runtime_tools ]
-  defp apps(_), do: [ :runtime_tools, :lager, :logger ]
+  defp apps(_), do: [ :runtime_tools, :lager, :logger, :sasl ]
 
   defp deps() do
     [

```

## Credits

Whole idea and example was created by *Brujo Benavides* and described in his article [here](https://medium.com/erlang-battleground/the-extinction-of-the-dodos-otp-style-f421f9de4275) as a part of *Erlang Battleground* series.

Translation to *Elixir* is done fully on our side.