defmodule RedisClone.Engine do

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> RedisClone.Engine.parse_command "GET shopping\r\n"
      {:ok, {:get, "shopping"}}

      iex> RedisClone.Engine.parse_command "PUT shopping milk\r\n"
      {:ok, {:put, "shopping", "milk"}}

      iex> RedisClone.Engine.parse_command "DELETE shopping\r\n"
      {:ok, {:del, "shopping"}}

      iex> RedisClone.Engine.parse_command "KEYS\r\n"
      {:ok, {:keys}}

  Multiple whitespace characters shouldn't be a problem:

      iex> RedisClone.Engine.parse_command "GET  shopping  \r\n"
      {:ok, {:get, "shopping"}}

  Unknown commands or commands with the wrong number of
  arguments return an error:

      iex> RedisClone.Engine.parse_command "UNKNOWN shopping eggs\r\n"
      {:error, :unknown_command}

      iex> RedisClone.Engine.parse_command "GET\r\n"
      {:error, :unknown_command}
  """
  def parse_command(line) do
    case String.split(line) do
      ["GET", key] -> {:ok, {:get, key}}
      ["PUT", key, value] -> {:ok, {:put, key, value}}
      ["DELETE", key] -> {:ok, {:del, key}}
      ["KEYS"] -> {:ok, {:keys}}
      _ -> {:error, :unknown_command}
    end
  end

  def run(table, {:get, key}) do
    {:ok, RedisClone.Storage.get(table, key)}
  end

  def run(table, {:put, key, value}) do
    RedisClone.Storage.put(table, key, value)
    {:ok, "OK\r\n"}
  end

  def run(table, {:del, key}) do
    RedisClone.Storage.delete(table, key)
    {:ok, "OK\r\n"}
  end

  def run(table, {:keys}) do
    {:ok, RedisClone.Storage.keys(table)}
  end
end