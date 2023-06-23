defmodule Viewbox.VodsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Viewbox.Vods` context.
  """
  alias Viewbox.AccountsFixtures

  @doc """
  Generate a vod.
  """
  def vod_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    {:ok, vod} =
      attrs
      |> Enum.into(%{
        user: user
      })
      |> Viewbox.Vods.create_vod()

    vod
  end
end
