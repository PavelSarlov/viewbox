defmodule ViewboxWeb.LivestreamController do
  use ViewboxWeb, :controller

  alias Viewbox.Accounts.User
  alias Viewbox.Repo
  alias Plug

  @output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")
  @output_file Application.compile_env(:viewbox, :stream_output_file, "index.m3u8")

  def index(conn, %{"username" => username}) do
    user = Repo.get_by!(User, username: username)

    render(conn, :index, user: user, output_file: @output_file)
  end

  def stream(conn, %{"username" => username, "filename" => filename}) do
    path = [@output_dir, username, "live", filename] |> Path.join() |> Path.expand()

    case File.exists?(path) do
      true ->
        conn |> Plug.Conn.send_file(200, path)

      false ->
        conn |> Plug.Conn.send_resp(404, "File not found")
    end
  end
end
