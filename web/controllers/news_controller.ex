defmodule Celeste.API.NewsController do
  use Celeste.Web, :controller

  require Ecto.Query

  alias Celeste.{Repo, Assemblage}

  def index(conn, _) do
    conn
    |> render("")
  end
end
