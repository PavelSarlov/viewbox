defmodule ViewboxWeb.LiveStreamLive do
  use ViewboxWeb, :live_view

  alias Viewbox.Accounts
  alias Viewbox.LiveMonitor
  alias Viewbox.LiveStream
  alias Plug

  @output_file Application.compile_env(:viewbox, :stream_live_file, "live.m3u8")

  def mount(%{"username" => username} = params, session, socket) do
    user = Accounts.get_user_by_username!(username)
    current_user = Accounts.get_user_by_session_token(session["user_token"], [:following])

    live_stream =
      LiveStream.get_live_stream(username: username)
      |> then(
        &LiveStream.update_live_stream(&1.socket, fn live_stream ->
          %{live_stream | viewer_count: live_stream.viewer_count + 1}
        end)
      )

    LiveMonitor.monitor(__MODULE__, params)

    Phoenix.PubSub.subscribe(Viewbox.PubSub, "live:#{username}")

    {:ok,
     assign(socket,
       user: user,
       output_file: @output_file,
       live_stream: live_stream,
       chat_messages: [],
       chat_form: to_form(%{}, as: "chat_form"),
       current_user: current_user,
       current_chat_input: ""
     )}
  end

  def unmount(_reason, %{"username" => username}) do
    LiveStream.get_live_stream(username: username)
    |> then(
      &LiveStream.update_live_stream(&1.socket, fn live_stream ->
        %{live_stream | viewer_count: max(0, live_stream.viewer_count - 1)}
      end)
    )
  end

  def unmount(_reason, _) do
  end

  def handle_info(%LiveStream{} = live_stream, socket) do
    {:noreply, assign(socket, live_stream: live_stream)}
  end

  def handle_info({:chat_message, message}, %{assigns: %{chat_messages: chat_messages}} = socket) do
    {:noreply, assign(socket, chat_messages: chat_messages ++ [message])}
  end

  def handle_event(
        "send_message",
        %{"chat_form" => %{"chat_input" => chat_input}},
        %{assigns: %{user: user, current_user: current_user}} = socket
      ) do
    Phoenix.PubSub.broadcast(
      Viewbox.PubSub,
      "live:#{user.username}",
      {:chat_message,
       %{
         "sender" =>
           case current_user do
             nil -> %{username: "Anonymous"}
             x -> x
           end,
         "timestamp" => DateTime.utc_now(),
         "content" => chat_input
       }}
    )

    {:noreply, assign(socket, current_chat_input: "")}
  end

  def handle_event(
        "toggle_follow",
        _,
        %{assigns: %{user: user, current_user: current_user}} = socket
      ) do
    {:ok, _} = Accounts.add_or_remove_follower(follower_id: current_user.id, streamer_id: user.id)
    current_user = Accounts.get_user!(current_user.id, [:following])

    {:noreply, assign(socket, current_user: current_user)}
  end

  def get_follow_btn_text(is_following) do
    case is_following do
      nil -> "Follow"
      _ -> "Unfollow"
    end
  end
end
