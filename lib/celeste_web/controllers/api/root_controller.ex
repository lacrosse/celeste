defmodule CelesteWeb.API.RootController do
  use CelesteWeb, :controller

  def ping(conn, _) do
    conn
    |> render("ping.json")
  end
end
