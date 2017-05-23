defmodule LibraryApp.Context do
  @behaviour Plug

  def init(opts) do
    opts
  end

  def call(conn, _) do
    conn
  end
end