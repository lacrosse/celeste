defmodule CelesteWeb.API.UserControllerTest do
  use CelesteWeb.ConnCase

  @tag :auth
  test "GET /api/user", %{conn: conn, user: user} do
    resp =
      conn
      |> get("/api/user")
      |> json_response(200)

    assert resp == %{"username" => user.username}
  end
end
