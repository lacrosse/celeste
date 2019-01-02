defmodule Celeste.Social.BorkleTest do
  use Celeste.ModelCase

  alias Celeste.Social.Borkle

  @valid_attrs %{user_id: 1, file_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Borkle.changeset(%Borkle{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Borkle.changeset(%Borkle{}, @invalid_attrs)
    refute changeset.valid?
  end
end
