defmodule Celeste.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :key, :string
      add :value, :string
      add :assemblage_id, references(:assemblages, on_delete: :nothing)

      timestamps()
    end

    create index(:tags, [:assemblage_id])
  end
end
