defmodule Viewbox.FileStorage do
  @moduledoc """
  `Membrane.HTTPAdaptiveStream.Storage` implementation that saves the stream to
  files locally based on the user's stream key.
  """
  @behaviour Membrane.HTTPAdaptiveStream.Storage

  @enforce_keys [:directory]
  defstruct @enforce_keys

  @type t :: %__MODULE__{
          directory: Path.t()
        }

  @impl true
  def init(%__MODULE__{} = config), do: config

  @impl true
  def store(
        _parent_id,
        name,
        contents,
        _metadata,
        %{mode: :binary},
        %__MODULE__{directory: location} = state
      ) do
    {File.write(build_output_folder(location, "asd", name), contents, [:binary]), state}
  end

  @impl true
  def store(
        _parent_id,
        name,
        contents,
        _metadata,
        %{mode: :text},
        %__MODULE__{directory: location} = state
      ) do
    {File.write(build_output_folder(location, "asd", name), contents), state}
  end

  @impl true
  def remove(_parent_id, name, _ctx, %__MODULE__{directory: location} = state) do
    {File.rm(build_output_folder(location, "asd", name)), state}
  end

  defp build_output_folder(location, username, name) do
    path = [location, username, "live", name] |> Path.join()

    File.mkdir_p!(Path.dirname(path))

    path
  end
end
