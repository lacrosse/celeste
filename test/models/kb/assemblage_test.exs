defmodule Celeste.KB.AssemblageTest do
  use Celeste.ModelCase

  alias Celeste.KB.Assemblage

  @valid_attrs %{name: "some content", kind: "person"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Assemblage.create_changeset(%Assemblage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Assemblage.create_changeset(%Assemblage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
