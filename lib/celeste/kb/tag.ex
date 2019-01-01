defmodule Celeste.KB.Tag do
  use Celeste.Web, :model

  schema "tags" do
    field :key, :string
    field :value, :string
    belongs_to :assemblage, Celeste.KB.Assemblage

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :value, :assemblage_id])
    |> validate_required([:key, :value, :assemblage_id])
  end
end
