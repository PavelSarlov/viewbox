defmodule ViewboxWeb.VodControllerTest do
  alias Viewbox.AccountsFixtures
  use ViewboxWeb.ConnCase

  describe "index" do
    test "lists all vods", %{conn: conn} do
      user = AccountsFixtures.user_fixture()

      conn = get(conn, ~p"/vods/#{user.username}")
      assert html_response(conn, 200) =~ "User #{user.username} vods"
    end
  end
end
