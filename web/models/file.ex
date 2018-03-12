defmodule Celeste.File do
  use Celeste.Web, :model

  schema "files" do
    many_to_many :assemblages, Celeste.Assemblage, join_through: "assemblages_files"
    has_many :borkles, Celeste.Borkle

    field :path, :string
    field :mime, :string
    field :size, :integer
    field :sha256, :binary
    field :seen_at, :naive_datetime
    field :atime, :naive_datetime
    field :mtime, :naive_datetime
    field :ctime, :naive_datetime
    field :id3v2, :map

    timestamps(updated_at: false)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:path, :mime, :size, :sha256, :seen_at, :atime, :mtime, :ctime, :id3v2])
    |> validate_required([:path, :mime, :size, :sha256, :seen_at, :atime, :mtime, :ctime])
  end

  def link_param(file), do: file.sha256 |> Base.encode16(case: :lower)

  def id3(file, key), do: with [value|_] = file.id3v2[key], do: value

  def jwt(file, user) do
    {:ok, jwt, _} =
      file
      |> Guardian.encode_and_sign(:access, %{u: user.id})

    jwt
  end

  def public_filename(%Celeste.File{mime: mime, sha256: sha256} = file) do
    [extension|_] = MIME.extensions(mime)
    name = sha256 |> Base.encode16(case: :lower)
    "#{name}.#{extension}"
  end
end
