defmodule CurrencyConverter.API do
  @default_currency "USD"

  def fetch(from, to \\ @default_currency)

  def fetch("BTC", to) do
    response = Tesla.get("https://blockchain.info/ticker")
    body = to_json(response.body())

    case response.status() do
      200 ->
        case body[to]["last"] do
          nil  -> {:error, :service_unavailable}
          rate -> {:ok, {"BTC", to, rate}}
        end

     _ ->
      {:error, :service_unavailable}
    end
  end

  def fetch(from, "BTC") do
    response = Tesla.get("https://blockchain.info/tobtc?currency=#{from}&value=1")
    body = response.body()

    case response.status() do
      200 ->
        case Float.parse(body) do
          :error    -> {:error, :service_unavailable}
          {rate, _} -> {:ok, {from, "BTC", rate}}
        end

      _ ->
        {:error, :service_unavailable}
    end
  end

  def fetch(from, to) do
    response = Tesla.get("http://api.fixer.io/latest?base=#{from}&symbols=#{to}")
    body = to_json(response.body())

    case response.status() do
      200 ->
        case body["rates"][to] do
          nil  -> {:error, :service_unavailable}
          rate -> {:ok, {from, to, rate}}
        end

      _ ->
        {:error, :service_unavailable}
    end
  end

  defp to_json(response) do
    Poison.decode!(response)
  end
end