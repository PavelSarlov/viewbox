defmodule Viewbox.Vods.Vod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vods" do
    belongs_to(:user, Viewbox.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(vod, attrs) do
    vod
    |> cast(attrs, [])
    |> validate_required([])
  end
end
