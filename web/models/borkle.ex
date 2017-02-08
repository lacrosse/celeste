defmodule Celeste.Borkle do
  use Celeste.Web, :model

  @primary_key false

  schema "borkles" do
    belongs_to :user, Celeste.File
    belongs_to :file, Celeste.File

    timestamps(updated_at: false)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :file_id])
    |> validate_required([:user_id, :file_id])
  end
end
