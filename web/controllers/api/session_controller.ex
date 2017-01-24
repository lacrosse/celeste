defmodule Celeste.API.SessionController do
  use Celeste.Web, :controller

  def create(conn, _) do
    conn
    |> render("show.json")
  end
end
