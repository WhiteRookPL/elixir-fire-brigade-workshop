defmodule Audiophile do
  use Application

  def start(_type, _args) do
    Audiophile.Supervisor.start_link()
  end

  def statistics() do
    Audiophile.Storage.statistics()
  end

  def scan(path) do
    Audiophile.Scanner.scan(path)
  end

  def scanning_history() do
    Audiophile.Scanner.history()
  end
end
