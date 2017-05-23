defmodule Chatterboxes.Blabber do
  use GenServer

  require Logger

  @frequency_in_ms 2_000

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def init(name) do
    Process.send_after(self(), :tick, @frequency_in_ms)

    <<i1 :: 32, i2 :: 32, i3 :: 32>> = :crypto.strong_rand_bytes(12)
    seed = :rand.seed_s(:exs1024, {i1, i2, i3})

    {value, new_seed} = Chatterboxes.random_from_range(seed, 100, 400)
    Process.send_after(self(), :tick, @frequency_in_ms + value)

    {:ok, {name, new_seed}}
  end

  def handle_info(:tick, {name, seed}) do
    {value, new_seed} = Chatterboxes.random_from_range(seed, 0, 100)

    Logger.info("Blabber '#{name}': #{value}")

    Chatterboxes.Statistics.calculate_statistics(value)
    Process.send_after(self(), :tick, @frequency_in_ms)

    {:noreply, {name, new_seed}}
  end
end