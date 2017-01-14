defmodule Celeste.PageController do
  use Celeste.Web, :controller

  def index(conn, _) do
    conn
    |> render("index.html")
  end
end
