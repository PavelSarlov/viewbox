defmodule ViewboxWeb.LiveStreamLive do
  use ViewboxWeb, :live_view

  alias Viewbox.Accounts.User
  alias Viewbox.Repo
  alias Plug

  @output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")
  @output_file Application.compile_env(:viewbox, :stream_output_file, "index.m3u8")

  def mount(%{"username" => username}, _session, socket) do
    user = Repo.get_by!(User, username: username)

    {:ok, assign(socket, user: user, output_file: @output_file)}
  end
end
