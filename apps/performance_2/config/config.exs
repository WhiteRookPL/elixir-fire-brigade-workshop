use Mix.Config

config :spell_checker_api,
  namespace: SpellCheckerAPI

config :spell_checker_api, SpellCheckerAPI.Web.Endpoint,
  url: [ host: "localhost" ],
  secret_key_base: "RkJ8bV99ullm0fB698y57ZKTfQlJaZdtcD/R/G8fQVs9Ziq6Npl2jxWF2Io9fzT8",
  render_errors: [ view: SpellCheckerAPI.Web.ErrorView, accepts: ~w(json) ],
  pubsub: [ name: SpellCheckerAPI.PubSub, adapter: Phoenix.PubSub.PG2 ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [ :request_id ]

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true

import_config "#{Mix.env}.exs"
