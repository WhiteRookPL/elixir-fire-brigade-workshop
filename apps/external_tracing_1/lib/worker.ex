defmodule LttngExample.Worker do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def work() do
    GenServer.call(__MODULE__, :work)
  end

  def init(:ok) do
    :ok = :lttng.add_handler(:lttng_example, "work", [ {{:erlang, :display, 1}, true} ])
    {:ok, []}
  end

  def handle_call(:work, _from, state) do
    :erlang.display(state)
    {:reply, :worked, state}
  end
end