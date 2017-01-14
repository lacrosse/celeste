defmodule Zongora.Repo.Migrations.CreateAssemblagesAssemblages do
  use Ecto.Migration

  def change do
    create table(:assemblages_assemblages, primary_key: false) do
      add :assemblage_id, references(:assemblages)
      add :child_assemblage_id, references(:assemblages)
    end

    create index(:assemblages_assemblages, [:assemblage_id])
    create index(:assemblages_assemblages, [:child_assemblage_id])
    create index(:assemblages_assemblages, [:assemblage_id, :child_assemblage_id], unique: true)
  end
end
