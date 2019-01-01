defmodule Celeste.Repo.Migrations.AlterBorklesScrobbled do
  use Ecto.Migration

  def change do
    Celeste.Social.Borkle
    |> Celeste.Repo.update_all(set: [scrobbled: false])

    alter table(:borkles) do
      modify(:scrobbled, :boolean, null: false)
    end
  end
end
