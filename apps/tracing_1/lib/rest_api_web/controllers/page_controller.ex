defmodule RestApiWeb.PageController do
  use RestApiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
