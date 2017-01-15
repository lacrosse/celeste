defmodule Celeste.AssemblageController do
  use Celeste.Web, :controller

  require Ecto.Query

  alias Celeste.{Assemblage, Assembly}

  def composers(conn, _) do
    assemblages =
      Celeste.Repo.all(
        Ecto.Query.from a in Assemblage,
          where: a.kind == "person",
          join: aa in Assembly,
          on: aa.assemblage_id == a.id,
          where: aa.kind == "composed",
          join: c in Assemblage,
          on: aa.child_assemblage_id == c.id,
          where: c.kind == "composition",
          group_by: [a.id],
          order_by: [a.name]
      )

    conn
    |> shallow_assemblages("Composers", assemblages)
  end

  def show(conn, %{"id" => id}) do
    query =
      from a in Assemblage,
      preload: [
        :tags,
        files: ^from(a in Celeste.File, order_by: :path)
      ]

    assemblage = Celeste.Repo.get!(query, id)

    conn
    |> assign(:assemblage, assemblage)
    |> assign(:page_title, assemblage.name)
    |> render("show.html")
  end

  def new(conn, _) do
    changeset = %Assemblage{} |> Ecto.Changeset.change()

    conn
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"assemblage" => assemblage_params}) do
    changeset =
      %Assemblage{}
      |> Assemblage.create_changeset(assemblage_params)

    case Repo.insert(changeset) do
      {:ok, a} ->
        conn
        |> put_flash(:info, "#{a.name} successfully created")
        |> redirect(to: assemblage_path(conn, :show, a.id))
      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    changeset =
      Repo.get!(Assemblage, id)
      |> Repo.preload(parent_assemblies: :assemblage)
      |> Repo.preload(child_assemblies: :child_assemblage)
      |> Ecto.Changeset.change()

    conn
    |> render("edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "assemblage" => assemblage_params}) do
    assemblage = Repo.get!(Assemblage, id)

    changeset =
      assemblage
      |> Assemblage.create_changeset(assemblage_params)
      |> IO.inspect

    conn
    |> render("edit.html", changeset: changeset)
  end

  defp shallow_assemblages(conn, name, assemblages) do
    assemblage = %{
      name: name,
      parent_assemblages: [],
      files: [],
      child_assemblages: assemblages
    }

    conn
    |> assign(:assemblage, assemblage)
    |> render("show.html")
  end
end
