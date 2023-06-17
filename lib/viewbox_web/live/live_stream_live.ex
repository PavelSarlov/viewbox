defmodule ViewboxWeb.LiveStreamLive do
  use ViewboxWeb, :live_view

  alias Viewbox.Accounts.User
  alias Viewbox.Repo
  alias Plug

  @output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")
  @output_file Application.compile_env(:viewbox, :stream_output_file, "index.m3u8")

  def render(assigns) do
    ~H"""
    <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>

    <%!-- <%= render_existing view_module(@conn), "_styles.html", assigns %> --%>

    <.header>
      Watching <strong><%= @user.username %></strong>
    </.header>

    <div class="container">
      <video id="player" autoplay class="Player"></video>
    </div>

    <script>
    var video = document.getElementById('player');
    var videoSrc = window.location.origin + `/api/stream/<%= @user.id %>/<%= @output_file %>`;
    if (Hls.isSupported()) {
      var hls = new Hls();
      hls.loadSource(videoSrc);
      hls.startLoad(0)
      hls.attachMedia(video);
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
      video.src = videoSrc;
    }
    </script>
    """
  end

  def mount(%{"username" => username}, _session, socket) do
    user = Repo.get_by!(User, username: username)

    {:ok, assign(socket, user: user, output_file: @output_file)}
  end
end
