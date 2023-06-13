defmodule Viewbox.LiveStream do
  use Membrane.Pipeline

  alias Membrane.HTTPAdaptiveStream.Sink
  alias Membrane.RTMP.SourceBin

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
        hls_mode: :muxed_av,
        mode: :live,
        storage: %Viewbox.FileStorage{
          directory: @stream_output_dir
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

  @impl true
  def handle_notification(
        {:socket_control_needed, _socket, _source} = notification,
        :src,
        _ctx,
        state
      ) do
    send(self(), notification)
    {:ok, state}
  end

  @impl true
  def handle_notification(_notification, _child, _ctx, state) do
    {:ok, state}
  end

  @impl true
  def handle_other({:socket_control_needed, socket, source} = notification, _ctx, state) do
    case SourceBin.pass_control(socket, source) do
      :ok ->
        :ok

      {:error, :not_owner} ->
        Process.send_after(self(), notification, 200)
    end

    {:ok, state}
  end

  def child_spec(opts) do
    %{
      id: Keyword.get(opts, :id, __MODULE__),
      start: {__MODULE__, :start_link, opts},
      restart: :transient
    }
  end
end
