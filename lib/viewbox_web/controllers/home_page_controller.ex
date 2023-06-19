defmodule ViewboxWeb.HomePageController do
  alias Viewbox.LiveStream
  use ViewboxWeb, :controller

  def index(conn, _params) do
    live_streams =
      Agent.get(Viewbox.SocketAgent, & &1)
      |> Map.values()
      |> Enum.map(fn live_stream ->
        Map.put(
          live_stream,
          :thumbnail,
          LiveStream.get_thumbnail(live_stream.user.id, nil)
        )
      end)

    render(conn, :index, live_streams: live_streams)
  end
end
