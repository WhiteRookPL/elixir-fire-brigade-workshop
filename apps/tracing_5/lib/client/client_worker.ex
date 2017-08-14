defmodule ClientAndServer.Client.Worker do
  use GenServer

  require Logger

  @tick_frequency_in_ms 3000
  @reconnect_timeout_in_ms 1000

  def start_link() do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    value = :base64.encode(:crypto.strong_rand_bytes(20))
    Process.send_after(self(), :reconnect, @reconnect_timeout_in_ms)

    {:ok, {:undefined, "#{value}\n"}}
  end

  def handle_info({:tcp, _port, message}, {_socket, value} = state) do
    stringified_message = String.trim(to_string(message))
    Logger.info("Received: #{stringified_message}, Equal: #{String.trim(value) == stringified_message}")

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _port}, {_socket, value}) do
    Process.send_after(self(), :reconnect, @reconnect_timeout_in_ms)
    Logger.info("Connection closed.")

    {:noreply, {:undefined, value}}
  end

  def handle_info(:reconnect, {_socket, value}) do
    port = Application.get_env(:client_and_server, :port)
    Logger.info("Connecting on #{port}...")

    new_socket = case :gen_tcp.connect('127.0.0.1', port, [ {:active, true} ]) do
      {:ok, socket} ->
        Process.send_after(self(), :tick, @tick_frequency_in_ms)
        socket

      {:error, _}   ->
        Process.send_after(self(), :reconnect, @reconnect_timeout_in_ms)
        :undefined
    end

    {:noreply, {new_socket, value}}
  end

  def handle_info(:tick, {:undefined, _value} = state) do
    {:noreply, state}
  end

  def handle_info(:tick, {socket, value} = state) do
    Logger.info("Sent:     #{String.trim(value)}")

    :ok = :gen_tcp.send(socket, value)

    Process.send_after(self(), :tick, @tick_frequency_in_ms)

    {:noreply, state}
  end
end