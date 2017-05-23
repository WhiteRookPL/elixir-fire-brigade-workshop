use Mix.Config

config :sentences_api, SentencesAPI.Web.Endpoint,
  http: [
    port: 4001
  ],
  server: false

config :logger,
  level: :warn,
  handle_otp_reports: false,
  handle_sasl_reports: false