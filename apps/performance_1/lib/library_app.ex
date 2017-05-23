defmodule LibraryApp do
  use Application

  def start(_type, _args) do
    LibraryApp.Supervisor.start_link()
  end
end