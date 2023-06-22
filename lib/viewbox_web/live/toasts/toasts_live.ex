defmodule ViewboxWeb.ToastsLive do
  use ViewboxWeb, :live_view

  import Phoenix.HTML.Link

  alias Viewbox.Accounts

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    Phoenix.PubSub.subscribe(Viewbox.PubSub, "toasts")

    {:ok, socket |> assign(current_user: current_user)}
  end

  def handle_info({:streamer_went_live, streamer}, socket) do
    following =
      case socket.assigns.current_user do
        nil -> []
        user -> Accounts.get_user!(user.id, [:following]).following
      end

    IO.inspect(following)

    updated_socket =
      case Enum.find(following, &(&1.id === streamer.id)) do
        nil ->
          socket

        _ ->
          toast = [link(streamer.username, to: "/live/#{streamer.username}"), " just went live!"]
          socket |> put_flash(:info, toast)
      end

    {:noreply, updated_socket}
  end
end
