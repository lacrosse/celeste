defmodule Celeste.AssemblageTest do
  use Celeste.ModelCase

  alias Celeste.Assemblage

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Assemblage.changeset(%Assemblage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Assemblage.changeset(%Assemblage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
