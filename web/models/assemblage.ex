defmodule Zongora.Assemblage do
  use Zongora.Web, :model

  alias Zongora.{Repo, Tag}

  schema "assemblages" do
    has_many :tags, Tag
    many_to_many :parent_assemblages, __MODULE__,
      join_through: "assemblies",
      join_keys: [child_assemblage_id: :id, assemblage_id: :id],
      unique: true
    many_to_many :child_assemblages, __MODULE__,
      join_through: "assemblies",
      join_keys: [assemblage_id: :id, child_assemblage_id: :id],
      unique: true
    many_to_many :files, Zongora.File,
      join_through: "assemblages_files"

    field :name, :string
    field :kind, :string

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :kind])
    |> validate_required([:name, :kind])
  end

  def child_assemblages_of_kind(assemblage, kind) do
    from ca in __MODULE__,
      join: aa in "assemblies", on: [child_assemblage_id: ca.id],
      join: a in ^__MODULE__, on: [id: aa.assemblage_id],
      where: a.id == ^assemblage.id and aa.kind == ^kind,
      order_by: [ca.name],
      preload: [:tags]
  end

  def parent_assemblages_of_kind(assemblage, kind) do
    from a in __MODULE__,
      join: aa in "assemblies", on: [assemblage_id: a.id],
      join: ca in ^__MODULE__, on: [id: aa.child_assemblage_id],
      where: ca.id == ^assemblage.id and aa.kind == ^kind,
      order_by: [a.name],
      preload: [:tags]
  end
end
