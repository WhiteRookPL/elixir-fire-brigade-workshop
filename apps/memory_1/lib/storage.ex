defmodule Audiophile.Storage do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def update({what, key}) when is_atom(what) and (what == :genre or what == :artist or what == :year) do
    GenServer.call(__MODULE__, {:increment_counter_in_table, what, key})
  end

  def statistics() do
    GenServer.call(__MODULE__, :statistics)
  end

  def init(:ok) do
    genres = :ets.new(:genres, [:private, :set, {:read_concurrency, true}, {:write_concurrency, true}])
    artists = :ets.new(:artists, [:private, :set, {:read_concurrency, true}, {:write_concurrency, true}])
    years = :ets.new(:year, [:private, :set, {:read_concurrency, true}, {:write_concurrency, true}])

    {:ok, %{ genres: genres, artists: artists, years: years}}
  end

  def handle_call({:increment_counter_in_table, :genre, key}, _from, %{ :genres => genres } = state) do
    update_counter(genres, key)
    {:reply, :updated, state}
  end

  def handle_call({:increment_counter_in_table, :artist, key}, _from, %{ :artists => artists } = state) do
    update_counter(artists, key)
    {:reply, :updated, state}
  end

  def handle_call({:increment_counter_in_table, :year, key}, _from, %{ :years => years } = state) do
    update_counter(years, key)
    {:reply, :updated, state}
  end

  def handle_call(:statistics, _from, state) do
    {:reply, statistics(state), state}
  end

  defp statistics(%{ :genres => genres, :artists => artists, :years => years }) do
    %{
      genres: get_all_and_sort(genres),
      artists: get_all_and_sort(artists),
      years: get_all_and_sort(years)
    }
  end

  defp get_all_and_sort(table) do
    :ets.tab2list(table)
    |> Enum.map(fn({key, value}) -> {pretty_print(key), value} end)
    |> Enum.sort(fn({_, value1}, {_, value2}) -> value1 >= value2 end)
  end

  defp pretty_print(raw) do
    String.codepoints(raw)
    |> Enum.filter(&String.valid?/1)
    |> Enum.filter(fn(codepoint) -> codepoint != <<0>> end)
    |> Enum.join("")
    |> String.trim()
  end

  defp update_counter(table, key) do
    :ets.update_counter(table, key, 1, {key, 0})
  end
end