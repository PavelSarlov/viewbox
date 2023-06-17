defmodule ViewboxWeb.HomePageController do
  use ViewboxWeb, :controller

  def index(conn, params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :index, layout: false)
  end
end
