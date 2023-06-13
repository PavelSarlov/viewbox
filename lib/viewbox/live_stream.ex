defmodule Viewbox.LiveStream do
  use Membrane.Pipeline

  alias Membrane.RTMP.SourceBin

  @stream_output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")

  @impl true
  def handle_init(opts) do
    socket =
      case Keyword.get(opts, :username) do
        nil ->
          Agent.get(Viewbox.SocketAgent, fn
            [] -> Keyword.get(opts, :socket)
            [socket | _] -> socket
          end)

        _ ->
          [socket | _] =
            Agent.get_and_update(Viewbox.SocketAgent, fn [socket | rest] ->
              {[socket | rest], rest}
            end)

          socket
      end

    spec = %ParentSpec{
      children: %{
        src: %SourceBin{socket: socket, validator: Viewbox.Validator},
        sink: %Membrane.HTTPAdaptiveStream.SinkBin{
          manifest_module: Membrane.HTTPAdaptiveStream.HLS,
          target_window_duration: :infinity,
          muxer_segment_duration: 10 |> Membrane.Time.seconds(),
          storage: %Viewbox.FileStorage{
            directory: @stream_output_dir
          }
        }
      },
      links: [
        link(:src)
        |> via_out(:audio)
        |> via_in(Pad.ref(:input, :audio), options: [encoding: :AAC])
        |> to(:sink),
        link(:src)
        |> via_out(:video)
        |> via_in(Pad.ref(:input, :video), options: [encoding: :H264])
        |> to(:sink)
      ]
    }

    {{:ok, spec: spec, playback: :playing}, %{socket: socket}}
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
