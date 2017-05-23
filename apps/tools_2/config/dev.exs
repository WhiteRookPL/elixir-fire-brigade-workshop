use Mix.Config

config :sentences_api, SentencesAPI.Web.Endpoint,
  http: [
    port: 4000,
    acceptors: 2
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20