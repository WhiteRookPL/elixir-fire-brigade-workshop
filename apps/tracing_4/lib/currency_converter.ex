defmodule CurrencyConverter do
  use Application

  def start(_type, _args) do
    CurrencyConverter.Supervisor.start_link()
  end

  def rate(from, to) do
    case CurrencyConverter.Converter.rate(from, to) do
      :no_rate_for_such_currency -> 0.0
      rate                       -> rate
    end
  end

  def exchange(from, to, value) do
    CurrencyConverter.rate(from, to) * value
  end

  def eur2pln(value) do
    CurrencyConverter.exchange("EUR", "PLN", value)
  end

  def usd2pln(value) do
    CurrencyConverter.exchange("USD", "PLN", value)
  end

  def pln2eur(value) do
    CurrencyConverter.exchange("PLN", "EUR", value)
  end

  def pln2usd(value) do
    CurrencyConverter.exchange("PLN", "USD", value)
  end

  def history() do
    CurrencyConverter.Converter.history()
  end

  def cache() do
    CurrencyConverter.Cache.list()
  end
end
