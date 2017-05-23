defmodule CurrencyConverter.Converter do
  use GenServer

  @refresh_frequency_in_ms 60_000

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def rate(from, to) do
    GenServer.call(__MODULE__, {:exchange_rate, from, to})
  end

  def history() do
    GenServer.call(__MODULE__, :history)
  end

  def init(:ok) do
    Process.send_after(self(), :refresh_cache, @refresh_frequency_in_ms)
    {:ok, []}
  end

  def handle_call({:exchange_rate, from, to}, _from, history) do
    rate = CurrencyConverter.Cache.rate(from, to)
    {:ok, date} = DateTime.from_unix(System.system_time(:second))

    {:reply, rate, [ {date, {from, to}, rate} | history ]}
  end

  def handle_call(:history, _from, history) do
    result =
      history
      |> Enum.reverse()
      |> Enum.map(fn({date, {from, to}, rate}) -> "#{DateTime.to_iso8601(date)}: 1 #{from} = #{rate} #{to}" end)

    {:reply, result, history}
  end

  def handle_info(:refresh_cache, history) do
    CurrencyConverter.Cache.refresh()

    Process.send_after(self(), :refresh_cache, @refresh_frequency_in_ms)

    {:noreply, history}
  end
end