defmodule RestApiWeb.ErrorViewTest do
  use RestApiWeb.ConnCase, async: true

  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(RestApiWeb.ErrorView, "404.html", []) ==
           "Page not found"
  end

  test "render 500.html" do
    assert render_to_string(RestApiWeb.ErrorView, "500.html", []) ==
           "Internal server error"
  end

  test "render any other" do
    assert render_to_string(RestApiWeb.ErrorView, "505.html", []) ==
           "Internal server error"
  end
end
