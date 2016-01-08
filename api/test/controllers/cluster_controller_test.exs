defmodule Api.ClusterControllerTest do
  use Api.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/api/"
    assert json_response(conn, 200)
  end
end
