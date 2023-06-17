defmodule ViewboxWeb.VodController do
  use ViewboxWeb, :controller

  alias Viewbox.Accounts
  alias Viewbox.Vods

  @output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")
  @output_file Application.compile_env(:viewbox, :stream_output_file, "index.m3u8")

  def index(conn, %{"username" => username}) do
    user = Accounts.get_user_by_username!(username)
    render(conn, :index, user: user)
  end

  def show(conn, %{"vod_id" => vod_id}) do
    vod = Vods.get_vod!(vod_id)
    render(conn, :show, vod: vod, output_file: @output_file)
  end

  def stream(conn, %{"user_id" => user_id, "vod_id" => vod_id, "filename" => filename}) do
    path =
      [@output_dir, user_id, vod_id, filename]
      |> Path.join()
      |> Path.expand()

    case File.exists?(path) do
      true ->
        conn |> Plug.Conn.send_file(200, path)

      false ->
        conn |> Plug.Conn.send_resp(404, "File not found")
    end
  end
end
