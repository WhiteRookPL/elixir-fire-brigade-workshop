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

    processed_files =
      files
      |> Enum.map(fn(filename) -> Audiophile.FileParser.extract_tags_from_mp3(filename) end)
      |> Enum.map(&maybe_print_error/1)
      |> Enum.filter(fn({result, _}) -> result == :ok end)
      |> Enum.map(fn({:ok, map}) -> Enum.map(map, &Audiophile.Storage.update/1) end)

    {:reply, :scanned, [ {path, length(processed_files)} | history ]}
  end

  defp maybe_print_error({:ok, _} = value), do: value
  defp maybe_print_error({:error, {filename, code}} = value) do
    Logger.error("  Error reading MP3 TAG: #{code}, file: #{filename}")
    value
  end

  defp file_description(1), do: "file"
  defp file_description(_), do: "files"
end