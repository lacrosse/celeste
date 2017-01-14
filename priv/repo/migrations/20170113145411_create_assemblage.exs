defmodule Zongora.Repo.Migrations.CreateAssemblage do
  use Ecto.Migration

  def change do
    create table(:assemblages) do
      add :name, :text

      timestamps()
    end
  end
end
