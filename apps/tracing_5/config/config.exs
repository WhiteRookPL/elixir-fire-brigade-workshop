use Mix.Config

config :client_and_server,
  :port, 4040

config :logger,
  handle_otp_reports: true,
  handle_sasl_reports: true