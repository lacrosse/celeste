defmodule Celeste.Repo.Migrations.AddScrobbledToBorkles do
  use Ecto.Migration

  def change do
    alter table(:borkles) do
      add :scrobbled, :boolean, default: false
    end
  end
end
