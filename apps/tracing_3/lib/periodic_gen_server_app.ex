defmodule PeriodicGenServerApp do
  use Application

  def start(_type, _args) do
    PeriodicGenServerApp.Supervisor.start_link()
  end
end
