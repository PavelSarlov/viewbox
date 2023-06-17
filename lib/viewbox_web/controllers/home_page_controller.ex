defmodule ViewboxWeb.HomePageController do
  use ViewboxWeb, :controller

  def index(conn, _params) do
    live_streams = Agent.get(Viewbox.SocketAgent, & &1) |> Map.values()

    render(conn, :index, live_streams: live_streams)
  end
end
