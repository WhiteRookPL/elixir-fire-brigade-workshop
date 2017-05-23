defmodule LibraryApp.Router do
  use Plug.Router

  plug Plug.Logger

  plug :match
  plug :dispatch

  plug Plug.Parsers,
    parsers: [ :urlencoded, :multipart, :json, Absinthe.Plug.Parser ],
    pass: [ "*/*" ],
    json_decoder: Poison

  plug LibraryApp.Context

  forward "/api", to: Absinthe.Plug, schema: LibraryApp.Schema

  match _ do
    send_resp(conn, 404, "Not found!")
  end
end