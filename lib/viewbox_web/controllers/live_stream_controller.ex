defmodule ViewboxWeb.LiveStreamController do
  use ViewboxWeb, :controller

  @output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")
  @output_file Application.compile_env(:viewbox, :stream_output_file, "index.m3u8")

  def stream(conn, %{"id" => id, "filename" => filename}) do
    path = [@output_dir, id, "live", filename] |> Path.join() |> Path.expand()

    case File.exists?(path) do
      true ->
        conn |> Plug.Conn.send_file(200, path)

      false ->
        conn |> Plug.Conn.send_resp(404, "File not found")
    end
  end
end
