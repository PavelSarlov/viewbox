defmodule Viewbox.Repo.Migrations.CreateFollowers do
  use Ecto.Migration

  def change do
    create table(:followers) do
      add(:follower_id, references(:users), null: false, primary_key: true)
      add(:streamer_id, references(:users), null: false, primary_key: true)

      timestamps()
    end

    create(unique_index(:followers, [:follower_id, :streamer_id]))
  end
end
