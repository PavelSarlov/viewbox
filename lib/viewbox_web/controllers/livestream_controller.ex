defmodule ViewboxWeb.LivestreamController do
  use ViewboxWeb, :controller

  alias Viewbox.Accounts.User
  alias Viewbox.Repo
  alias Plug

  @output_dir Application.compile_env(Viewbox, :output_dir, "output")
  @stream_file Application.compile_env(Viewbox, :stream_file, "index.m3u8")

  def index(conn, %{"username" => username}) do
    user = Repo.get_by!(User, username: username)

    render(conn, :index, user: user)
  end

  def stream(conn, %{"username" => username}) do
    path = Path.join([@output_dir, username, "live"])

    if File.exists?(path) do
      conn |> Plug.Conn.send_file(200, path)
    else
      conn |> Plug.Conn.send_resp(404, "File not found")
    end
  end
end
