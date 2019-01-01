defmodule Celeste.KB.Assembly do
  use Celeste.Web, :model

  alias Celeste.KB.Assemblage

  schema "assemblies" do
    belongs_to :assemblage, Assemblage
    belongs_to :child_assemblage, Assemblage

    field :kind, :string
  end
end
