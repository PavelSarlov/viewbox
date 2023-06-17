defmodule Viewbox.VodsTest do
  use Viewbox.DataCase

  alias Viewbox.Vods

  describe "vods" do
    alias Viewbox.Vods.Vod

    import Viewbox.VodsFixtures

    @invalid_attrs %{}

    test "list_vods/0 returns all vods" do
      vod = vod_fixture()
      assert Vods.list_vods() == [vod]
    end

    test "get_vod!/1 returns the vod with given id" do
      vod = vod_fixture()
      assert Vods.get_vod!(vod.id) == vod
    end

    test "create_vod/1 with valid data creates a vod" do
      valid_attrs = %{}

      assert {:ok, %Vod{} = vod} = Vods.create_vod(valid_attrs)
    end

    test "create_vod/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Vods.create_vod(@invalid_attrs)
    end

    test "update_vod/2 with valid data updates the vod" do
      vod = vod_fixture()
      update_attrs = %{}

      assert {:ok, %Vod{} = vod} = Vods.update_vod(vod, update_attrs)
    end

    test "update_vod/2 with invalid data returns error changeset" do
      vod = vod_fixture()
      assert {:error, %Ecto.Changeset{}} = Vods.update_vod(vod, @invalid_attrs)
      assert vod == Vods.get_vod!(vod.id)
    end

    test "delete_vod/1 deletes the vod" do
      vod = vod_fixture()
      assert {:ok, %Vod{}} = Vods.delete_vod(vod)
      assert_raise Ecto.NoResultsError, fn -> Vods.get_vod!(vod.id) end
    end

    test "change_vod/1 returns a vod changeset" do
      vod = vod_fixture()
      assert %Ecto.Changeset{} = Vods.change_vod(vod)
    end
  end
end
