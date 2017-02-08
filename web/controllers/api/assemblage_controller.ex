defmodule Celeste.API.AssemblageController do
  use Celeste.Web, :controller

  alias Celeste.{Repo, Assemblage}

  def show(conn, %{"id" => id}) do
    assemblage =
      Repo.get!(Assemblage, id)
      |> Repo.preload(:parent_assemblies)
      |> Repo.preload(:child_assemblies)
      |> Repo.preload(parent_assemblages: :tags)
      |> Repo.preload(child_assemblages: :tags)
      |> Repo.preload(:files)
      |> Repo.preload(:tags)

    conn
    |> render("show.json", assemblage: assemblage, user: Guardian.Plug.current_resource(conn))
  end

  def composers(conn, _) do
    assemblages =
      Repo.all(Assemblage.composers_query())

    conn
    |> render("index.json", assemblages: assemblages)
  end
end
