defmodule Zongora.File do
  use Zongora.Web, :model

  schema "files" do
    many_to_many :assemblages, Zongora.Assemblage, join_through: "assemblages_files"

    field :path, :string
    field :mime, :string
    field :size, :integer
    field :sha256, :binary
    field :seen_at, :naive_datetime
    field :atime, :naive_datetime
    field :mtime, :naive_datetime
    field :ctime, :naive_datetime

    timestamps(updated_at: false)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:path, :mime, :size, :sha256, :seen_at, :atime, :mtime, :ctime])
    |> validate_required([:path, :mime, :size, :sha256, :seen_at, :atime, :mtime, :ctime])
  end

  def link_param(file), do: file.sha256 |> Base.encode16(case: :lower)
end
