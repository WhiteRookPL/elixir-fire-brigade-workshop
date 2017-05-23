use Mix.Config

config :sentences_api,
  namespace: SentencesAPI

config :sentences_api, SentencesAPI.Web.Endpoint,
  url: [ host: "localhost" ],
  secret_key_base: "HZNlpRdVobBKuHp2unMWkHw8b0f7dSOvOz835gGOyiww1bgvpEvkFrcm/EDucEfz",
  render_errors: [ view: SentencesAPI.Web.ErrorView, accepts: ~w(html json) ],
  pubsub: [
    name: SentencesAPI.PubSub,
    adapter: Phoenix.PubSub.PG2
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [ :request_id ]

import_config "#{Mix.env}.exs"