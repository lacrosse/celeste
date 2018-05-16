defmodule CelesteWeb.API.RootController do
  use Celeste.Web, :controller

  def ping(conn, _) do
    conn
    |> render("ping.json")
  end
end
