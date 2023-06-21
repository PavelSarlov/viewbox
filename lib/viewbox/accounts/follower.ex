defmodule Viewbox.Accounts.Follower do
  use Ecto.Schema
  import Ecto.Changeset

  alias Viewbox.Accounts.User

  schema "followers" do
    belongs_to(:streamer, User, foreign_key: :streamer_id, references: :id)
    belongs_to(:follower, User, foreign_key: :follower_id, references: :id)

    timestamps()
  end

  @doc false
  def changeset(follower, attrs \\ %{}) do
    follower
    |> cast(attrs, [:follower_id, :streamer_id])
    |> validate_required([:follower_id, :streamer_id])
    |> unique_constraint([:follower_id, :streamer_id])
  end
end
