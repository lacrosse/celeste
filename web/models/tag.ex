defmodule Zongora.Tag do
  use Zongora.Web, :model

  schema "tags" do
    field :key, :string
    field :value, :string
    belongs_to :assemblage, Zongora.Assemblage

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :value, :assemblage_id])
    |> validate_required([:key, :value, :assemblage_id])
  end
end
