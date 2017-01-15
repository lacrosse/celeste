defmodule Celeste.File do
  use Celeste.Web, :model

  @id3v2_fields [:TALB, :TCOM, :TIT2, :TRCK, :TXXX, :TYER, :PRIV]

  schema "files" do
    many_to_many :assemblages, Celeste.Assemblage, join_through: "assemblages_files"

    embeds_one :id3v2, ID3v2 do
      field :TCOM, {:array, :string}
      field :TIT2, {:array, :string}
      field :TRCK, {:array, :string}
      field :TALB, {:array, :string}
      field :TYER, {:array, :string}
      field :TXXX, {:array, :string}
      field :PRIV, {:array, :string}
    end

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
    |> cast_embed(:id3v2, with: &id3v2_changeset/2)
    |> validate_required([:path, :mime, :size, :sha256, :seen_at, :atime, :mtime, :ctime])
  end

  defp id3v2_changeset(schema, params) do
    surplus = params |> Map.keys |> Enum.map(&String.to_atom/1) |> MapSet.new() |> MapSet.difference(MapSet.new(@id3v2_fields))

    if not Enum.empty?(surplus), do: IO.inspect(params)

    schema
    |> cast(params, @id3v2_fields)
  end

  def link_param(file), do: file.sha256 |> Base.encode16(case: :lower)
end
