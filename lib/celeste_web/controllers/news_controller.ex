defmodule CelesteWeb.API.NewsController do
  use Celeste.Web, :controller

  require Ecto.Query

  def index(conn, _) do
    conn
    |> render("")
  end
end
