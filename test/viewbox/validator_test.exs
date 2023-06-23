defmodule Viewbox.ValidatorTest do
  use Viewbox.DataCase

  alias Viewbox.AccountsFixtures

  @validator %Viewbox.Validator{socket: nil}

  describe("validator") do
    test "validates release stream" do
      assert {:ok, "stream released"} =
               Membrane.RTMP.MessageValidator.validate_release_stream(
                 @validator,
                 "some message"
               )
    end

    test "validates set data frame" do
      assert {:ok, "set data frame successful"} =
               Membrane.RTMP.MessageValidator.validate_set_data_frame(
                 @validator,
                 "some message"
               )
    end

    test "validates publish stream with correct stream key" do
      user = AccountsFixtures.user_fixture()
      {:ok, stream_key} = Ecto.UUID.load(user.stream_key)

      assert {:ok, "publish stream successful"} =
               Membrane.RTMP.MessageValidator.validate_publish(
                 @validator,
                 %{stream_key: "#{user.username}_#{stream_key}"}
               )
    end

    test "invalidates publish stream with incorrect stream key" do
      user = AccountsFixtures.user_fixture()

      assert {:error, "bad stream key"} =
               Membrane.RTMP.MessageValidator.validate_publish(
                 @validator,
                 %{stream_key: "#{user.username}_wrong"}
               )
    end

    test "invalidates publish stream with non-existent user" do
      assert {:error, "unknown user"} =
               Membrane.RTMP.MessageValidator.validate_publish(
                 @validator,
                 %{stream_key: "who_?"}
               )
    end
  end
end
