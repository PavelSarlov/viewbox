defmodule ViewboxWeb.UserSettingsLiveTest do
  use ViewboxWeb.ConnCase

  alias Viewbox.Accounts
  import Phoenix.LiveViewTest
  import Viewbox.AccountsFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/settings")

      assert html =~ "Change username"
      assert html =~ "Change Password"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update username form" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = user_fixture(%{password: password})
      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "updates the user username", %{conn: conn, password: password} do
      new_username = unique_username()

      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      lv
      |> form("#username_form", %{
        "current_password" => password,
        "user" => %{"username" => new_username}
      })
      |> render_submit()

      assert Accounts.get_user_by_username!(new_username)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> element("#username_form")
        |> render_change(%{
          "action" => "update_username",
          "current_password" => "invalid",
          "user" => %{"username" => "a"}
        })

      assert result =~ "Change username"
      assert result =~ "should be at least 3 character(s)"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#username_form", %{
          "current_password" => "invalid",
          "user" => %{"username" => user.username}
        })
        |> render_submit()

      assert result =~ "Change username"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = user_fixture(%{password: password})
      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "user" => %{
            "password" => "short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 8 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "user" => %{
            "password" => "short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 8 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end
end
