defmodule Audiophile.Storage do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def update(key, time) do
    GenServer.call(__MODULE__, {:add_time, :artist, key, time})
  end

  def statistics() do
    GenServer.call(__MODULE__, :statistics)
  end

  def init(:ok) do
    artists = :ets.new(:artists, [:private, :set, {:read_concurrency, true}, {:write_concurrency, true}])

    {:ok, %{ artists: artists}}
  end

  def handle_call({:add_time, :artist, key, time}, _from, %{ :artists => artists } = state) do
    update_counter(artists, key, time)
    {:reply, :updated, state}
  end

  def handle_call(:statistics, _from, state) do
    {:reply, statistics(state), state}
  end

  defp statistics(%{ :artists => artists }) do
    %{
      artists: get_all_and_sort(artists)
    }
  end

  defp get_all_and_sort(table) do
    :ets.tab2list(table)
    |> Enum.sort(fn({_, value1}, {_, value2}) -> value1 >= value2 end)
    |> Enum.map(&apply_human_friendly_time_representation/1)
  end

  defp update_counter(table, key, time) do
    :ets.update_counter(table, key, time, {key, 0})
  end

  defp apply_human_friendly_time_representation({key, time}) when time == 0, do: {key, "0s"}
  defp apply_human_friendly_time_representation({key, time}) do
    hours = div(time, 3600)
    minutes = div(rem(time, 3600), 60)
    seconds = rem(rem(time, 3600), 60)

    {key, "#{hours}h #{minutes}min #{seconds}s"}
  end
end