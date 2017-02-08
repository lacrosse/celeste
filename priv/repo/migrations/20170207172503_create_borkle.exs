defmodule Celeste.Repo.Migrations.CreateBorkle do
  use Ecto.Migration

  def change do
    create table(:borkles, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing)
      add :file_id, references(:files, on_delete: :nothing)

      add :inserted_at, :timestamp, null: false
    end

    create index(:borkles, [:user_id])
    create index(:borkles, [:file_id])
  end
end
