defmodule Celeste.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Celeste.Repo
  alias Celeste.User

  def for_token(%User{id: id}), do: {:ok, "user:#{id}"}
  def for_token(_), do: {:error, "unknown resource type"}

  def from_token("user:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "unknown resource type"}
end
