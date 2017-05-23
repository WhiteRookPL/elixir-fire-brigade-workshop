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
    postfix = :base64.encode(:crypto.strong_rand_bytes(20))
    new_atom = String.to_atom("new_atom_#{postfix}")

    :erlang.send_after(delay, self(), :timeout)

    Logger.debug("New atom created: #{new_atom}")
    {:noreply, {delay, [ new_atom | acc ]}}
  end
end