defmodule Celeste.Repo.Migrations.AddId3v2ToFiles do
  use Ecto.Migration

  def change do
    alter table(:files) do
      add :id3v2, :jsonb
    end
  end
end
