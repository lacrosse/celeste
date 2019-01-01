defmodule Celeste.KB.TagTest do
  use Celeste.ModelCase

  alias Celeste.KB.Tag

  @valid_attrs %{key: "some content", value: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
