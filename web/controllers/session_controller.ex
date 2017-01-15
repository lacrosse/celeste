defmodule Celeste.SessionController do
  use Celeste.Web, :controller

  alias Celeste.User

  def new(conn, _) do
    params = %{session: %{username: "", password: ""}}

    conn
    |> render("new.html", params: params)
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}} = params) do
    case User.authenticate(username, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Logged in!")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: page_path(conn, :index))
      :error ->
        conn
        |> put_flash(:error, "Not authenticated")
        |> render("new.html", params: %{session: %{username: username}})
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
