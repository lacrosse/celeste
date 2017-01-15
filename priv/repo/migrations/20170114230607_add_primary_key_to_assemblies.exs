defmodule Celeste.Repo.Migrations.AddPrimaryKeyToAssemblies do
  use Ecto.Migration

  def change do
    execute "alter table assemblies add column id serial primary key"
  end
end
