defmodule PeriodicGenServerApp.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(PeriodicGenServerApp.Printer, [])

      # After enabling this line our PeriodicGenServer stops working:
      # worker(PeriodicGenServerApp.Interrogator, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end