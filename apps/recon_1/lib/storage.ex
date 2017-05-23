defmodule RedisClone.Storage do
  def initialize(name) do
    :ets.new(name, [:public, :set, {:read_concurrency, true}])
  end

  def put(name, key, value) do
    :ets.insert(name, {key, value})
  end

  def get(name, key) do
    case :ets.lookup(name, key) do
      [ {_key, value} ] -> value
      []                -> :nothing
    end
  end

  def delete(name, key) do
    :ets.delete(name, key)
  end

  def keys(name) do
    keys_stream(name) |> Enum.take(100) |> Enum.join(",")
  end

  defp keys_stream(name) do
    Stream.resource(
      fn -> :ets.first(name) end,
      fn :"$end_of_table" -> {:halt, nil}
         previous_key -> {[previous_key], :ets.next(name, previous_key)} end,
      fn _ -> :ok end)
  end
end