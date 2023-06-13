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
  def store(name, contents, %{mode: :binary}, %__MODULE__{directory: location}) do
    File.write(build_output_folder(location, "asd", name), contents, [:binary])
  end

  @impl true
  def store(name, contents, %{mode: :text}, %__MODULE__{directory: location}) do
    File.write(build_output_folder(location, "asd", name), contents)
  end

  @impl true
  def remove(name, _ctx, %__MODULE__{directory: location}) do
    File.rm(build_output_folder(location, "asd", name))
  end

  defp build_output_folder(location, username, name) do
    path = [location, username, "live", name] |> Path.join()

    File.mkdir_p!(Path.dirname(path))

    path
  end
end
