defmodule Celeste.Repo.Migrations.RenameAssemblagesAssemblagesToAssemblies do
  use Ecto.Migration

  def change do
    rename table(:assemblages_assemblages), to: table(:assemblies)
  end
end
