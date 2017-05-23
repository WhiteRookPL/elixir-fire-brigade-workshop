defmodule RandomServer.Randomizer do
  use GenServer

  # Public API.

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def change_algorithm(algo \\ :exs64) do
    GenServer.call(__MODULE__, {:change_algorithm, algo})
  end

  def range(min, max) when max > min do
    GenServer.call(__MODULE__, {:range, min, max})
  end

  def rand() do
    GenServer.call(__MODULE__, {:uniform})
  end

  def randomize_list(input) do
    GenServer.call(__MODULE__, {:shuffle, input})
  end

  def history() do
    GenServer.call(__MODULE__, {:history})
  end

  # Callbacks.

  def init(:ok) do
    seed = :rand.seed_s(:exs64)

    {:ok, %{ :seed => seed, :history => [] }}
  end

  def handle_call({:change_algorithm, algo} = command, _from, state) do
    <<i1 :: 32, i2 :: 32, i3 :: 32>> = :crypto.strong_rand_bytes(12)
    seed = :rand.seed_s(algo, {i1, i2, i3})

    {:reply, {:changed, seed}, modify_state(state, command, "<NEW SEED>", seed)}
  end

  def handle_call({:range, min, max} = command, _from, state) do
    seed = Map.get(state, :seed)

    {new_value, new_seed} = :rand.uniform_s(seed)
    value = Kernel.trunc(Float.floor(new_value * (max - min + 1)) + min)

    {:reply, {:result, value}, modify_state(state, command, value, new_seed)}
  end

  def handle_call({:uniform} = command, _from, state) do
    seed = Map.get(state, :seed)

    {value, new_seed} = :rand.uniform_s(seed)

    {:reply, {:result, value}, modify_state(state, command, value, new_seed)}
  end

  def handle_call({:shuffle, list} = command, _from, state) do
    value = Enum.shuffle(list)

    {:reply, {:result, value}, modify_state(state, command, value)}
  end

  def handle_call({:history}, _from, state) do
    commands = Map.get(state, :history)

    {:reply, {:history, prepare(commands)}, state}
  end

  # Private helpers.

  defp format_command({:change_algorithm, algo}), do: "change_randomizer_algorithm(#{algo})"
  defp format_command({:range, min, max}), do: "random_from_range(#{min}, #{max})"
  defp format_command({:uniform}), do: "uniform()"
  defp format_command({:shuffle, list}), do: "shuffle(#{inspect list})"

  defp modify_state(state, command, result) do
    history = Map.get(state, :history)

    %{ state | :history => [ {format_command(command), result} | history ] }
  end

  defp modify_state(state, command, result, seed) do
    updated_state = modify_state(state, command, result)

    %{ updated_state | :seed => seed }
  end

  defp prepare(list) do
    prepare(list, [])
  end

  defp prepare([], acc), do: acc
  defp prepare([ {command, result} | _tail ] = list, acc) when is_list(result), do: prepare(list, [ "#{command} = #{inspect result}" | acc ])
  defp prepare([ {command, result} | _tail ] = list, acc), do: prepare(list, [ "#{command} = #{result}" | acc ])
end