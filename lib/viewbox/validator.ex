defmodule Viewbox.Validator do
  use Membrane.RTMP.MessageValidator

  @impl true
  def validate_release_stream(release) do
    {:ok, "release stream success"}
  end

  @impl true
  def validate_publish(message) do
    {:ok, "publish success"}
  end
end
