defmodule Viewbox.VodsTest do
  use Viewbox.DataCase

  alias Viewbox.AccountsFixtures
  alias Viewbox.Vods

  describe "vods" do
    alias Viewbox.Vods.Vod

    import Viewbox.VodsFixtures

    test "list_vods/0 returns all vods" do
      vod = vod_fixture()
      assert Vods.list_vods([:user]) == [vod]
    end

    test "get_vod!/1 returns the vod with given id" do
      vod = vod_fixture()
      assert Vods.get_vod!(vod.id, [:user]) == vod
    end

    test "create_vod/1 with valid data creates a vod" do
      valid_attrs = %{user: AccountsFixtures.user_fixture()}

      assert {:ok, %Vod{}} = Vods.create_vod(valid_attrs)
    end
  end
end
