defmodule Celeste.Repo.Migrations.CreateAssemblagesFiles do
  use Ecto.Migration

  def change do
    create table(:assemblages_files, primary_key: false) do
      add :assemblage_id, references(:assemblages)
      add :file_id, references(:files)
    end

    create index(:assemblages_files, [:assemblage_id])
    create index(:assemblages_files, [:assemblage_id, :file_id], unique: true)
  end
end
