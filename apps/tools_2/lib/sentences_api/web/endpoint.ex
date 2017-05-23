defmodule SentencesAPI.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :sentences_api

  plug Plug.Static,
    at: "/", from: :sentences_api, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_sentences_api_key",
    signing_salt: "f9xwCg7J"

  plug SentencesAPI.Web.Router

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def load_from_system_env(config) do
    port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
    {:ok, Keyword.put(config, :http, [ :inet6, port: port ])}
  end
end
