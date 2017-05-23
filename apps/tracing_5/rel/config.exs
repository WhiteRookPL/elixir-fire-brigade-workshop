use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

cookie_dev = :"DEV_COOKIE"
environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: cookie_dev
  set overlay_vars: [ cookie: cookie_dev ]
  set vm_args: "rel/vm.args"
end

cookie_prod = :"PROD_COOKIE"
environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: cookie_prod
  set overlay_vars: [ cookie: cookie_prod ]
  set vm_args: "rel/vm.args"
end

release :client_and_server do
  set version: "1.0.0"
  set applications: [
    sasl: :permanent,
    logger: :permanent,
    client_and_server: :permanent,
    runtime_tools: :permanent,
    xprof: :permanent,
    recon: :permanent,
    eper: :permanent,
    dbg: :permanent
  ]
end