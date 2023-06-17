defmodule Viewbox.FileStorage do
  @moduledoc """
  `Membrane.HTTPAdaptiveStream.Storage` implementation that saves the stream to
  files locally based on the user's stream key.
  """
  @behaviour Membrane.HTTPAdaptiveStream.Storage

  @enforce_keys [:location, :socket]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          location: Path.t(),
          socket: port()
        }

  alias Viewbox.LiveStream

  @stream_live_dir Application.compile_env(:viewbox, :stream_live_dir, "live")

  @impl true
  def init(%__MODULE__{} = config), do: config

  @impl true
  def store(
        _parent_id,
        name,
        contents,
        _metadata,
        %{mode: :binary},
        state
      ) do
    {File.write(build_output_folder(state, name), contents, [:binary]), state}
  end

  @impl true
  def store(
        _parent_id,
        name,
        contents,
        _metadata,
        %{mode: :text},
        state
      ) do
    {File.write(build_output_folder(state, name), contents), state}
  end

  @impl true
  def remove(_parent_id, name, _ctx, state) do
    {File.rm(build_output_folder(state, name)), state}
  end

  defp build_output_folder(state, name) do
    %LiveStream{user: user} =
      Agent.get(Viewbox.SocketAgent, fn
        sockets -> Map.fetch!(sockets, state.socket)
      end)

    path = [state.location, Integer.to_string(user.id), @stream_live_dir, name] |> Path.join()
    File.mkdir_p!(Path.dirname(path))
    path
  end
end
