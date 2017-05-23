defmodule CurrencyConverter.Cache do
  use GenServer

  @table_name __MODULE__

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def save_rate(from, to, rate) do
    GenServer.call(__MODULE__, {:cache_rate, from, to, rate})
  end

  def rate(from, to) do
    GenServer.call(__MODULE__, {:rate, from, to})
  end

  def list() do
    GenServer.call(__MODULE__, :list_cached_currencies)
  end

  def refresh() do
    GenServer.cast(__MODULE__, :refresh)
  end

  def init(:ok) do
    table = :ets.new(@table_name, [:private, :set, {:read_concurrency, true}, {:write_concurrency, true}])

    {:ok, table}
  end

  def handle_cast(:refresh, table) do
    :ets.delete_all_objects(table)

    currencies(table)
    |> Enum.map(fn({from, to}) -> CurrencyConverter.API.fetch(from, to) end)

    {:noreply, table}
  end

  def handle_call({:cache_rate, from, to, rate}, _from, table) do
    save(table, {from, to}, rate)
    {:reply, :cached, table}
  end

  def handle_call({:rate, from, to}, _from, table) do
    response = case :ets.lookup(table, {from, to}) do
      [ {_, rate} ] ->
        rate

      _ ->
        case CurrencyConverter.API.fetch(from) do
          {:ok, {from, to, rate}} ->
            save(table, {from, to}, rate)
            rate

          {:error, _} ->
            :no_rate_for_such_currency
        end
    end

    {:reply, response, table}
  end

  def handle_call(:list_cached_currencies, _from, table) do
    {:reply, currencies(table), table}
  end

  defp currencies(table) do
    :ets.tab2list(table)
    |> Enum.map(fn({currency, _}) -> currency end)
  end

  defp save(table, key, value) do
    :ets.insert(table, {key, value})
  end
end