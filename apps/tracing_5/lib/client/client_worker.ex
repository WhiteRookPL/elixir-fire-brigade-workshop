defmodule ClientAndServer.Client.Worker do
  use GenServer

  require Logger

  @tick_frequency_in_ms 3000

  def start_link() do
    port = Application.get_env(:client_and_server, :port)
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', port, [ {:active, true} ])

    Process.send_after(self(), :tick, @tick_frequency_in_ms)
    value = :base64.encode(:crypto.strong_rand_bytes(20))

    {:ok, {socket, "#{value}\n"}}
  end

  def handle_info({:tcp, _port, message}, {_socket, value} = state) do
    stringified_message = String.trim(to_string(message))
    Logger.info("Received: #{stringified_message}, Equal: #{String.trim(value) == stringified_message}")

    {:noreply, state}
  end

  def handle_info(:tick, {socket, value} = state) do
    Logger.info("Sent:     #{String.trim(value)}")

    :ok = :gen_tcp.send(socket, value)

    Process.send_after(self(), :tick, @tick_frequency_in_ms)

    {:noreply, state}
  end
end