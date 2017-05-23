defmodule SentencesAPI.Web.SentencesControllerTest do
  use SentencesAPI.Web.ConnCase

  test "GET /api/sentences", %{ conn: conn } do
    conn = get conn, "/api/sentences"
    response = json_response(conn, 200)["sentences"]

    assert length(response) == 33
  end

  test "GET /api/sentences/random", %{ conn: conn } do
    conn = get conn, "/api/sentences/random"
    response = json_response(conn, 200)["sentences"]

    assert length(response) == 1
  end
end
