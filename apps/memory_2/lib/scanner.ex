defmodule Audiophile.Scanner do
  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def scan(path) do
    GenServer.call(__MODULE__, {:scan, path}, :infinity)
  end

  def history() do
    GenServer.call(__MODULE__, :history)
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_call(:history, _from, history) do
    result =
      history
      |> Enum.reverse()
      |> Enum.map(fn({path, count}) -> {path, count, file_description(count)} end)
      |> Enum.map(fn({path, count, description}) -> "We processed #{count} #{description} inside: #{path}" end)

    {:reply, result, history}
  end

  def handle_call({:scan, path}, _from, history) do
    files = Path.wildcard("#{path}/**/*.mp3")

    processed_tags =
      files
      |> Flow.from_enumerable(stages: 8, max_demand: 1)
      |> Flow.map(fn(filename) -> {filename, Audiophile.FileParser.extract_duration(filename)} end)
      |> Flow.map(fn({filename, length}) -> {Audiophile.FileParser.extract_tags_from_mp3(filename), length} end)
      |> Flow.map(&maybe_print_error/1)
      |> Flow.filter(fn({{result, _}, _}) -> result == :ok end)
      |> Flow.filter(fn({_, {result, _}}) -> result == :ok end)
      |> Flow.map(&store_and_collect_id3_tag/1)
      |> Enum.to_list()

    cleanup()

    {:reply, :scanned, [ {path, length(processed_tags)} | history ]}
  end

  defp store_and_collect_id3_tag({{:ok, %{ :artist => artist, :id3 => id3 }}, {:ok, time}}) do
    Audiophile.Storage.update(artist, time)
    id3
  end

  defp maybe_print_error({{:ok, _}, _} = value), do: value
  defp maybe_print_error({{:error, {filename, code}}, _} = value) do
    Logger.error("  Error reading MP3 TAG: #{code}, file: #{filename}")
    value
  end

  defp file_description(1), do: "file"
  defp file_description(_), do: "files"

  defp cleanup() do
    :erts_debug.set_internal_state(:available_internal_state, true)
    :erts_debug.set_internal_state(:test_long_gc_sleep, 100)

    :erlang.garbage_collect()

    :erts_debug.set_internal_state(:test_long_gc_sleep, 0)
    :erts_debug.set_internal_state(:available_internal_state, false)
  end
end