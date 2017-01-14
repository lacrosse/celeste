defmodule Celeste.Repo.Migrations.CreateFile do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :path, :text
      add :mime, :string
      add :size, :integer
      add :sha256, :binary
      add :seen_at, :naive_datetime
      add :atime, :naive_datetime
      add :mtime, :naive_datetime
      add :ctime, :naive_datetime

      timestamps(updated_at: false)
    end

    create index(:files, [:sha256])
    create index(:files, [:path], unique: true)
  end
end
