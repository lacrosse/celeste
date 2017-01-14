defmodule Zongora.PageController do
  use Zongora.Web, :controller

  def index(conn, _) do
    conn
    |> render("index.html")
  end
end
