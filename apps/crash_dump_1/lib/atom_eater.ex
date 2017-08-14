defmodule Crasher.AtomEater do
  use GenServer

  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    delay = Crasher.random_from_range(1, 10)

    {:ok, {delay, []}, delay}
  end

  def handle_info(:timeout, {delay, acc}) do
    new_atom = String.to_existing_atom("new_atom")

    :erlang.send_after(delay, self(), :timeout)

    Logger.debug("New atom created: #{new_atom}")
    {:noreply, {delay, [ new_atom | acc ]}}
  end
end