defmodule Zongora.AssemblageController do
  use Zongora.Web, :controller

  require Ecto.Query

  def composers(conn, _) do
    assemblages =
      Zongora.Repo.all(
        Ecto.Query.from a in Zongora.Assemblage,
          where: a.kind == "person",
          join: aa in "assemblies",
          on: aa.assemblage_id == a.id,
          where: aa.kind == "composed",
          join: c in Zongora.Assemblage,
          on: aa.child_assemblage_id == c.id,
          where: c.kind == "composition",
          group_by: [a.id],
          order_by: [a.name]
      )

    conn
    |> Zongora.AssemblageController.shallow_assemblages("Composers", assemblages)
  end

  def show(conn, %{"id" => id}) do
    query =
      from a in Zongora.Assemblage,
      preload: [
        :tags,
        files: ^from(a in Zongora.File, order_by: :path)
      ]

    assemblage = Zongora.Repo.get!(query, id)

    conn
    |> assign(:assemblage, assemblage)
    |> assign(:page_title, assemblage.name)
    |> render "#{assemblage.kind}.html"
  end

  def shallow_assemblages(conn, name, assemblages) do
    assemblage = %{
      name: name,
      parent_assemblages: [],
      files: [],
      child_assemblages: assemblages
    }

    conn
    |> assign(:assemblage, assemblage)
    |> render "show.html"
  end
end
