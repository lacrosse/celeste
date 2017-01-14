defmodule Zongora.Repo.Migrations.AddKindToAssemblagesAssemblages do
  use Ecto.Migration

  def change do
    alter table(:assemblages_assemblages) do
      add :kind, :string
    end
  end
end
