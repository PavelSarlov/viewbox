defmodule Viewbox.LiveStream do
  use Membrane.Pipeline

  alias Viewbox.LiveStream
  alias Viewbox.Vods
  alias Membrane.HTTPAdaptiveStream.Sink
  alias Membrane.RTMP.SourceBin

  @enforce_keys ~w()a
  @optional_keys ~w(user socket)a
  @default_keys [is_live?: false, viewer_count: 0]
  defstruct @enforce_keys ++ @optional_keys ++ @default_keys

  @type t :: %__MODULE__{
          viewer_count: non_neg_integer(),
          socket: port(),
          user: Accounts.User.t(),
          is_live?: boolean()
        }

  @stream_output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")

  @impl true
  def handle_init(_ctx, socket: socket, validator: validator, use_ssl?: use_ssl?) do
    segment_duration = %Sink.SegmentDuration{
      min: 2 |> Membrane.Time.seconds(),
      target: 4 |> Membrane.Time.seconds()
    }

    spec = [
      child(:src, %SourceBin{
        socket: socket,
        validator: validator,
        use_ssl?: use_ssl?
      }),
      child(:sink, %Membrane.HTTPAdaptiveStream.SinkBin{
        manifest_module: Membrane.HTTPAdaptiveStream.HLS,
        persist?: true,
        target_window_duration: :infinity,
        mode: :live,
        hls_mode: :muxed_av,
        storage: %Viewbox.FileStorage{
          location: @stream_output_dir,
          socket: socket
        }
      }),
      get_child(:src)
      |> via_out(:audio)
      |> via_in(Pad.ref(:input, :audio),
        options: [encoding: :AAC, segment_duration: segment_duration]
      )
      |> get_child(:sink),
      get_child(:src)
      |> via_out(:video)
      |> via_in(Pad.ref(:input, :video),
        options: [encoding: :H264, segment_duration: segment_duration]
      )
      |> get_child(:sink)
    ]

    {[spec: spec, playback: :playing], %{socket: socket}}
  end

  # Once the source initializes, we grant it the control over the tcp socket
  @impl true
  def handle_child_notification(
        {:socket_control_needed, _socket, _source} = notification,
        :src,
        _ctx,
        state
      ) do
    send(self(), notification)

    {[], state}
  end

  def handle_child_notification(notification, _child, _ctx, state)
      when notification in [:end_of_stream, :socket_closed, :unexpected_socket_closed] do
    Membrane.Pipeline.terminate(self())
    {[], state}
  end

  def handle_child_notification(_notification, _child, _ctx, state) do
    {[], state}
  end

  @impl true
  def handle_info({:socket_control_needed, socket, source} = notification, _ctx, state) do
    case Membrane.RTMP.SourceBin.pass_control(socket, source) do
      :ok ->
        nil

      {:error, :not_owner} ->
        Process.send_after(self(), notification, 200)

      {:error, :closed} ->
        Membrane.Pipeline.terminate(self())
    end

    {[], state}
  end

  # The rest of the module is used for self-termination of the pipeline after processing finishes
  @impl true
  def handle_element_end_of_stream(:sink, _pad, _ctx, state) do
    {[terminate: :shutdown], state}
  end

  @impl true
  def handle_element_end_of_stream(_child, _pad, _ctx, state) do
    {[], state}
  end

  @impl true
  def handle_terminate_request(_ctx, state) do
    Agent.update(Viewbox.SocketAgent, fn sockets ->
      %{user: user} = Map.get(sockets, state.socket)
      Vods.create_vod(%{user: user})
      Map.delete(sockets, state.socket)
    end)

    {[], state}
  end

  def get_live_streams() do
    Agent.get(Viewbox.SocketAgent, fn sockets ->
      Map.values(sockets)
    end)
  end

  def get_live_stream(username: username) do
    case get_live_streams()
         |> Enum.find(fn live_stream -> live_stream.user.username == username end) do
      nil -> %LiveStream{}
      x -> x
    end
  end

  def get_live_stream(socket: socket) do
    case Agent.get(Viewbox.SocketAgent, fn sockets -> sockets[socket] end) do
      nil -> %LiveStream{}
      x -> x
    end
  end

  def get_live_stream(_), do: nil

  def update_live_stream(nil, _), do: %LiveStream{}

  def update_live_stream(socket, update_fn) when is_function(update_fn, 1) do
    Agent.update(Viewbox.SocketAgent, fn sockets ->
      case sockets[socket] do
        nil ->
          sockets

        live_stream ->
          %{
            sockets
            | socket => Map.merge(live_stream, update_fn.(live_stream))
          }
      end
    end)

    live_stream = get_live_stream(socket: socket)

    case live_stream.user do
      nil ->
        nil

      user ->
        Phoenix.PubSub.broadcast(
          Viewbox.PubSub,
          "live:#{user.username}",
          live_stream
        )
    end

    live_stream
  end
end
