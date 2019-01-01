defmodule CelesteWeb.API.SessionController do
  use Celeste.Web, :controller

  alias Celeste.Social.User

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    case User.authenticate(username, password) do
      {:ok, user} ->
        conn =
          conn
          |> Guardian.Plug.api_sign_in(user)

        jwt = Guardian.Plug.current_token(conn)
        {:ok, claims} = Guardian.Plug.claims(conn)
        exp = Map.get(claims, "exp")

        conn
        |> put_resp_header("x-expires", to_string(exp))
        |> render("show.json", user: user, jwt: jwt, exp: exp)

      :error ->
        conn
        |> put_status(401)
        |> render("error.json", message: "Not authenticated")
    end
  end
end
