defmodule TreasureHunt.Chest do
  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def open() do
    GenServer.call(__MODULE__, :open_chest, :infinity)
  end

  def init(:ok) do
    case Application.get_env(:treasure_hunt, :key, -1) do
      1 -> Process.send_after(self(), :tick, 20)
      4 -> Process.send_after(self(), :tick, 20)
      7 -> Process.send_after(self(), :tick, 20)
      9 -> Process.send_after(self(), :tick, 20)
      _ -> nil
    end

    {:ok, []}
  end

  def handle_call(:open_chest, _from, state) do
    key = Application.get_env(:treasure_hunt, :key, -1)

    case key do
      -1 ->
        sorted_node_list = Node.list(:hidden) |> Enum.sort()
        :rpc.multicall(sorted_node_list ++ [ Node.self() ], :init, :stop, [])
        {:reply, :nothing, state}

      0 ->
        TreasureHunt.Bomb.explode()
        {:reply, :nothing, state}

      1 ->
        result = Application.get_env(:treasure_hunt, :answer1, 44)
        {:reply, result, state}

      # Value `2` is not there deliberately as it should crash
      # and wind up .

      3 ->
        {:reply, :stop, :stopped, state}

      4 ->
        :init.stop()
        {:reply, :nothing, state}

      5 ->
        TreasureHunt.Bomb.explode()
        {:reply, :nothing, state}

      6 ->
        {:reply, :stop, :stopped, state}

      7 ->
        result = Application.get_env(:treasure_hunt, :answer2, 42)
        {:reply, result, state}

      8 ->
        pid = spawn_link(fn() -> receive do end end)
        send(pid, :knock_knock)

        result = receive do
          :who_is_there -> :nothing
        end

        {:reply, result, state}

      9 ->
        {:reply, :nothing, state}

      10 ->
        sorted_node_list = Node.list() |> Enum.sort()
        :rpc.multicall(sorted_node_list ++ [ Node.self() ], :init, :stop, [])
        {:reply, :nothing, state}
    end
  end

  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, 20)

    garbage = :base64.encode(:crypto.strong_rand_bytes(128))
    Logger.error("#{garbage}")

    {:noreply, state}
  end
end