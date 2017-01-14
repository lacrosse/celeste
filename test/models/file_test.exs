defmodule Zongora.FileTest do
  use Zongora.ModelCase

  alias Zongora.File

  @valid_attrs %{mime: "some content", path: "some content", sha256: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = File.changeset(%File{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = File.changeset(%File{}, @invalid_attrs)
    refute changeset.valid?
  end
end
