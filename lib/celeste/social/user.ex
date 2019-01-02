defmodule Celeste.Social.User do
  use CelesteWeb, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2, dummy_checkpw: 0]

  alias Celeste.Repo

  schema "users" do
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:lastfm_username, :string)
    field(:lastfm_key, :string)

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> encrypt_password()
  end

  def authenticate(username, password) do
    with {:db, %__MODULE__{} = user} <- {:db, Repo.get_by(__MODULE__, username: username)},
         {:bcrypt, true} <- {:bcrypt, checkpw(password, user.password_hash)} do
      {:ok, user}
    else
      {:db, _} ->
        dummy_checkpw()
        :error

      {:bcrypt, _} ->
        :error
    end
  end

  defp encrypt_password(struct) do
    if struct.valid? do
      encrypted_password =
        struct
        |> get_change(:password)
        |> hashpwsalt()

      struct
      |> delete_change(:password)
      |> put_change(:password_hash, encrypted_password)
    else
      struct
    end
  end
end
