defmodule Celeste.Social.Borkle do
  use Celeste.Web, :model

  @primary_key false

  schema "borkles" do
    belongs_to(:user, Celeste.Social.User)
    belongs_to(:file, Celeste.Content.File)

    field(:scrobbled, :boolean)

    timestamps(updated_at: false)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :file_id])
    |> validate_required([:user_id, :file_id])
  end
end
