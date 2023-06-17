defmodule Viewbox.Validator do
  @enforce_keys [:socket]
  defstruct @enforce_keys
end

defimpl Membrane.RTMP.MessageValidator, for: Viewbox.Validator do
  alias Viewbox.Accounts.User
  alias Viewbox.LiveStream
  alias Viewbox.Accounts

  @impl true
  def validate_release_stream(impl, message) do
    validate_stream_key(impl, message.stream_key)
  end

  @impl true
  def validate_publish(impl, message) do
    validate_stream_key(impl, message.stream_key)
  end

  @impl true
  def validate_set_data_frame(_impl, _message) do
    {:ok, "set data frame successful"}
  end

  @spec validate_stream_key(Membrane.RTMP.MessageValidator.t(), String.t()) ::
          {:error, any()} | {:ok, any()}
  defp validate_stream_key(impl, stream_key) do
    [username, stream_key] = String.split(stream_key, "_")

    case Accounts.get_user_by_username!(username) do
      nil ->
        {:error, "unknown user"}

      %User{stream_key: bin_stream_key} = user ->
        case Ecto.UUID.dump(stream_key) do
          {:ok, ^bin_stream_key} ->
            Agent.update(Viewbox.SocketAgent, fn sockets ->
              Map.put(sockets, impl.socket, %LiveStream{viewer_count: 0, user: user})
            end)

            {:ok, "publish stream success"}

          _ ->
            {:error, "bad stream key"}
        end
    end
  end
end
