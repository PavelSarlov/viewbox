defmodule Viewbox.FileStorageTest do
  alias Viewbox.LiveStream
  use Viewbox.DataCase

  describe("file storage") do
    import Viewbox.FileStorageFixtures
    import Viewbox.AccountsFixtures

    setup do
      File.rm_rf("test_output")

      user = user_fixture()
      file_storage = file_storage_fixture()

      Agent.update(Viewbox.SocketAgent, fn sockets ->
        Map.put(sockets, file_storage.socket, %LiveStream{socket: file_storage.socket, user: user})
      end)

      %{file_storage: file_storage, user: user, file_name: "manifest.m3u8"}
    end

    test "creates parent dirs and stores contents in given filename for user", %{
      file_storage: file_storage,
      user: user,
      file_name: file_name
    } do
      {:ok, contents} = File.read("test/support/static/#{file_name}")

      file_storage.__struct__.store(nil, file_name, contents, nil, %{mode: :text}, file_storage)

      file_storage.__struct__.store(
        nil,
        "a#{file_name}",
        contents,
        nil,
        %{mode: :binary},
        file_storage
      )

      assert File.exists?("test_output/#{user.id}/live/#{file_name}")
      assert File.exists?("test_output/#{user.id}/live/a#{file_name}")
    end

    test "prepares manifest for live streaming", %{
      file_storage: file_storage,
      user: user,
      file_name: file_name
    } do
      {:ok, contents} = File.read("test/support/static/#{file_name}")
      {:ok, live_contents} = File.read("test/support/static/live_#{file_name}")

      file_storage.__struct__.store(nil, file_name, contents, nil, %{mode: :text}, file_storage)

      assert File.exists?("test_output/#{user.id}/live/#{file_name}")
      assert File.exists?("test_output/#{user.id}/live/live.m3u8")
      assert {:ok, ^live_contents} = File.read("test_output/#{user.id}/live/live.m3u8")
    end
  end
end
