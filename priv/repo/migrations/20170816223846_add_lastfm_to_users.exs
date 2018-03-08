defmodule Celeste.Repo.Migrations.AddLastfmToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :lastfm_username, :string
      add :lastfm_key, :string
    end
  end
end
