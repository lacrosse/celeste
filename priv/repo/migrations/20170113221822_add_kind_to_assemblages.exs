defmodule Zongora.Repo.Migrations.AddKindToAssemblages do
  use Ecto.Migration

  def change do
    alter table(:assemblages) do
      add :kind, :string
    end
  end
end
