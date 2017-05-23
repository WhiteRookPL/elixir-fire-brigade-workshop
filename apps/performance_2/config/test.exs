use Mix.Config

config :spell_checker_api, SpellCheckerAPI.Web.Endpoint,
  http: [
    port: 4001
  ],
  server: false

config :logger, level: :warn