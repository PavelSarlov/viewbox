defmodule Viewbox.LiveStream do
  use Membrane.Pipeline

  alias Membrane.HTTPAdaptiveStream.Sink
  alias Membrane.RTMP.SourceBin

  @enforce_keys ~w(viewer_count user)a
  defstruct @enforce_keys

  @stream_output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")

  @impl true
  def handle_init(_ctx, socket: socket, validator: validator, use_ssl?: use_ssl?) do
    segment_duration = %Sink.SegmentDuration{
      min: 8 |> Membrane.Time.seconds(),
      target: 10 |> Membrane.Time.seconds()
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

  def handle_child_notification(_notification, _child, _ctx, state) do
    {[], state}
  end

  @impl true
  def handle_info({:socket_control_needed, socket, source} = notification, _ctx, state) do
    case Membrane.RTMP.SourceBin.pass_control(socket, source) do
      :ok ->
        :ok

      {:error, :not_owner} ->
        Process.send_after(self(), notification, 200)
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
end
