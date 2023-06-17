defmodule Viewbox.VodsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Viewbox.Vods` context.
  """

  @doc """
  Generate a vod.
  """
  def vod_fixture(attrs \\ %{}) do
    {:ok, vod} =
      attrs
      |> Enum.into(%{

      })
      |> Viewbox.Vods.create_vod()

    vod
  end
end
