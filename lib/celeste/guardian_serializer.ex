defmodule Celeste.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Celeste.{Repo}
  alias Celeste.Social.User
  alias Celeste.Content.File, as: CFile

  def for_token(%User{id: id}), do: {:ok, "u:#{id}"}
  def for_token(%CFile{id: id}), do: {:ok, "f:#{id}"}
  def for_token(_), do: {:error, "unknown resource type"}

  def from_token("u:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token("f:" <> id), do: {:ok, Repo.get(CFile, id)}
  def from_token(_), do: {:error, "unknown resource type"}
end
