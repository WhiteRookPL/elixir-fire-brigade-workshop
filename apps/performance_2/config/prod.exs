use Mix.Config

config :spell_checker_api, SpellCheckerAPI.Web.Endpoint,
  on_init: {SpellCheckerAPI.Web.Endpoint, :load_from_system_env, []},
  url: [
    host: "localhost",
    port: 80
  ]

config :logger, level: :info

import_config "prod.secret.exs"