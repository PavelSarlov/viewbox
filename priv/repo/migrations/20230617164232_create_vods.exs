defmodule Viewbox.Repo.Migrations.CreateVods do
  use Ecto.Migration

  def change do
    create table(:vods) do
      add(:user_id, references(:users))

      timestamps()
    end
  end
end
