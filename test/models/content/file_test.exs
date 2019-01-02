defmodule Celeste.Content.FileTest do
  use Celeste.ModelCase

  alias Celeste.Content.File

  @valid_attrs %{
    mime: "some content",
    path: "some content",
    sha256: "some content",
    size: 12,
    seen_at: DateTime.utc_now(),
    atime: DateTime.utc_now(),
    ctime: DateTime.utc_now(),
    mtime: DateTime.utc_now()
  }
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
