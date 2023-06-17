defmodule ViewboxWeb.VodControllerTest do
  use ViewboxWeb.ConnCase

  import Viewbox.VodsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all vods", %{conn: conn} do
      conn = get(conn, ~p"/vods")
      assert html_response(conn, 200) =~ "Listing Vods"
    end
  end

  describe "new vod" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/vods/new")
      assert html_response(conn, 200) =~ "New Vod"
    end
  end

  describe "create vod" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/vods", vod: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/vods/#{id}"

      conn = get(conn, ~p"/vods/#{id}")
      assert html_response(conn, 200) =~ "Vod #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/vods", vod: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Vod"
    end
  end

  describe "edit vod" do
    setup [:create_vod]

    test "renders form for editing chosen vod", %{conn: conn, vod: vod} do
      conn = get(conn, ~p"/vods/#{vod}/edit")
      assert html_response(conn, 200) =~ "Edit Vod"
    end
  end

  describe "update vod" do
    setup [:create_vod]

    test "redirects when data is valid", %{conn: conn, vod: vod} do
      conn = put(conn, ~p"/vods/#{vod}", vod: @update_attrs)
      assert redirected_to(conn) == ~p"/vods/#{vod}"

      conn = get(conn, ~p"/vods/#{vod}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, vod: vod} do
      conn = put(conn, ~p"/vods/#{vod}", vod: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Vod"
    end
  end

  describe "delete vod" do
    setup [:create_vod]

    test "deletes chosen vod", %{conn: conn, vod: vod} do
      conn = delete(conn, ~p"/vods/#{vod}")
      assert redirected_to(conn) == ~p"/vods"

      assert_error_sent 404, fn ->
        get(conn, ~p"/vods/#{vod}")
      end
    end
  end

  defp create_vod(_) do
    vod = vod_fixture()
    %{vod: vod}
  end
end
