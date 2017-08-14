defmodule Crasher.MemoryEater do
  use GenServer

  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    delay = Crasher.random_from_range(1000, 3000)

    {:ok, :nothing, delay}
  end

  def handle_info(:timeout, :nothing) do
    list = 0 .. 100 |> Enum.take(100)

    infinite_reverse(list, [])

    {:noreply, :nothing}
  end

  defp infinite_reverse([], result), do: result
  defp infinite_reverse([ head | tail ], acc), do: infinite_reverse(tail, [ head | acc ])
end