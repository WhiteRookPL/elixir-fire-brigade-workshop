defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry with the given `name`.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) when is_atom(server) do
    case :ets.lookup(server, name) do
      [{^name, bucket}] -> {:ok, bucket}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  @doc """
  Deletes a bucket associated to the given `name` in `server`.
  """
  def delete(server, name) do
    GenServer.call(server, {:delete, name})
  end

  @doc """
  Looks up all the buckets stored in `server`.

  Returns list of buckets.
  """
  def buckets(server) do
    GenServer.call(server, :buckets)
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  ## Server callbacks

  def init(table) do
    names = :ets.new(table, [:duplicate_bag, :named_table])
    refs  = %{}

    {:ok, {names, refs}}
  end

  def handle_call({:create, name}, _from, {names, refs}) do
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}

      :error ->
        {:ok, pid} = KV.Bucket.Supervisor.start_bucket()

        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)

        :ets.insert(names, {name, pid})

        {:reply, pid, {names, refs}}
    end
  end

  def handle_call({:delete, name}, _from, {names, refs}) do
    case lookup(names, name) do
      {:ok, pid} ->
        Agent.stop(pid, :normal)
        {:reply, :bucket_deleted, {names, refs}}

      :error ->
        {:reply, :no_such_bucket, {names, refs}}
    end
  end

  def handle_call(:buckets, _from, {names, refs}) do
    keys =
      :ets.tab2list(names)
      |> Enum.map(fn ({key, _}) -> key end)
      |> Enum.sort()

    {:reply, keys, {names, refs}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)

    :ets.delete(names, name)

    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
   {:noreply, state}
  end
end
