defmodule ViewboxWeb.NavbarLive do
  use ViewboxWeb, :live_view

  def mount(params, session, socket) do
    Phoenix.PubSub.subscribe(Viewbox.PubSub, "navbar:notifications")

    {:ok, socket}
  end

  def handle_info({:start_stream}, socket) do
    {:noreply, socket}
  end
end
