defmodule Viewbox.Validator do
  alias Viewbox.Accounts.User
  alias Viewbox.Repo

  defstruct []
end

defimpl Membrane.RTMP.MessageValidator, for: Viewbox.Validator do
  @impl true
  def validate_release_stream(impl, message) do
    validate_stream_key(message.stream_key)
  end

  @impl true
  def validate_publish(impl, message) do
    validate_stream_key(message.stream_key)
  end

  @impl true
  def validate_set_data_frame(impl, message) do
    {:ok, "set data frame successful"}
  end

  @spec validate_stream_key(String.t()) :: {:error, any()} | {:ok, any()}
  defp validate_stream_key(stream_key) do
    case Ecto.UUID.dump(stream_key) do
      :error ->
        {:error, "bad stream key"}

      {:ok, stream_key} ->
        case Repo.get_by(User, stream_key: stream_key) do
          nil ->
            {:error, "invalid stream key"}

          user ->
            # somehow pass username to correct sink
            {:ok, "publish stream success"}
        end
    end
  end
end
