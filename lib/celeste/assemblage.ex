defmodule Celeste.Assemblage do
  use Celeste.Web, :model

  alias Celeste.{Tag, Assembly}
  alias Celeste.File, as: CFile

  schema "assemblages" do
    has_many :tags, Tag
    has_many :parent_assemblies, Assembly, foreign_key: :child_assemblage_id
    has_many :child_assemblies, Assembly, foreign_key: :assemblage_id
    has_many :parent_assemblages, through: [:parent_assemblies, :assemblage]
    has_many :child_assemblages, through: [:child_assemblies, :child_assemblage]
    many_to_many :files, CFile, join_through: "assemblages_files"

    field :name, :string
    field :kind, :string

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :kind])
    |> validate_required([:name, :kind])
  end

  def child_assemblages_of_kind(assemblage, assembly_kind, assemblage_kind) do
    from ca in __MODULE__,
      join: aa in "assemblies", on: [child_assemblage_id: ca.id],
      join: a in ^__MODULE__, on: [id: aa.assemblage_id],
      where: a.id == ^assemblage.id and aa.kind == ^assembly_kind and ca.kind == ^assemblage_kind,
      order_by: [ca.name],
      preload: [:tags]
  end

  def parent_assemblages_of_kind(assemblage, assembly_kind, assemblage_kind) do
    from a in __MODULE__,
      join: aa in "assemblies", on: [assemblage_id: a.id],
      join: ca in ^__MODULE__, on: [id: aa.child_assemblage_id],
      where: ca.id == ^assemblage.id and aa.kind == ^assembly_kind and a.kind == ^assemblage_kind,
      order_by: [a.name],
      preload: [:tags]
  end

  def composers_query do
    from a in __MODULE__,
      where: a.kind == "person",
      join: aa in Assembly,
      on: aa.assemblage_id == a.id,
      where: aa.kind == "composed",
      join: c in ^__MODULE__,
      on: aa.child_assemblage_id == c.id,
      where: c.kind == "composition",
      group_by: [a.id],
      order_by: [a.name]
  end
end
