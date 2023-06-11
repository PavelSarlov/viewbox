defmodule Viewbox.Repo.Migrations.AddUsers do
  use Ecto.Migration

  @table_name "users"

  def up do
    create table(@table_name) do
      add(:username, :string)
      add(:password, :string)
      add(:stream_key, :binary)

      timestamps()
    end
  end

  def down do
    drop(table(@table_name))
  end
end
