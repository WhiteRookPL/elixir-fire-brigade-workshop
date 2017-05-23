use Mix.Config

config :sentences_api, SentencesAPI.Web.Endpoint,
  on_init: {SentencesAPI.Web.Endpoint, :load_from_system_env, []},
  url: [ host: "localhost", port: 80 ],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"