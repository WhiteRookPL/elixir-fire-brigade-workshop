defmodule KV.Bucket do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket` and expire it after `ttl` milliseconds.
  """
  def putx(bucket, key, value, ttl) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

  @doc """
  Gets a stream of values from the `bucket` by `key`.
  """
  def get_stream(bucket, key) do
    create_stream_from_value(get(bucket, key))
  end

  @doc """
  Get all keys in the provided `bucket`.
  """
  def keys(bucket) do
    bucket
    |> Agent.get(&Map.keys/1)
    |> Enum.sort()
  end

  # Private functions.

  defp create_stream_from_value(value) do
    Stream.resource(fn () -> prepare_all_lines(value) end, &prepare_line/1, &noop/1)
  end

  defp prepare_all_lines(long_string) do
    String.split(long_string, "\n")
  end

  defp prepare_line(lines) do
    case Enum.count(lines) > 0 do
      true  ->
        line = Enum.take(lines, 1)
        rest = Enum.slice(lines, 1, Enum.count(lines))

        {line, rest};

      false ->
        {:halt, ""}
    end
  end

  defp noop(_empty_word_list) do
    nil
  end
end
