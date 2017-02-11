defmodule Celeste.Borkfm do
  alias Celeste.Borkle

  def bork(file, user) do
    %Borkle{}
    |> Borkle.changeset(%{user_id: user.id, file_id: file.id})
    |> Repo.insert!()
  end
end
