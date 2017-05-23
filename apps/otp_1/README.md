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

## Credits

Whole idea and example was created by *Brujo Benavides* and described in his article [here](https://medium.com/erlang-battleground/the-extinction-of-the-dodos-otp-style-f421f9de4275) as a part of *Erlang Battleground* series.

Translation to *Elixir* is done fully on our side.