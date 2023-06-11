defmodule Viewbox.Validator do
  alias Viewbox.Accounts.User
  alias Viewbox.Repo
  use Membrane.RTMP.MessageValidator

  @impl true
  def validate_publish(message) do
    IO.inspect(message)
    validate_stream_key(message.stream_key)
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
            {:ok, "publish stream success"}
        end
    end
  end
end
