use Mix.Releases.Config,
  default_environment: :prod

cookie_prod = :"enter_the_treasure_hunt"
environment :prod do
  set include_erts: true
  set include_system_libs: true
  set include_src: false
  set cookie: cookie_prod
  set overlay_vars: [ cookie: cookie_prod ]
  set vm_args: "rel/vm.args"
end

for i <- 1..10 do
  release String.to_atom("treasure_hunt_node_#{i}") do
    set version: "1.0.0"
    set applications: [
      crypto: :permanent,
      logger: :permanent,
      treasure_hunt: :permanent,
      runtime_tools: :permanent,
      recon: :permanent
    ]
  end
end