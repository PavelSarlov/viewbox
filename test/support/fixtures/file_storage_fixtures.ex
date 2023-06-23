defmodule Viewbox.FileStorageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Viewbox.FileStorage` context.
  """
  alias Viewbox.FileStorage

  @stream_output_dir Application.compile_env(:viewbox, :stream_output_dir, "test_output")

  @doc """
  Generate a file storage struct.
  """
  def file_storage_fixture() do
    %FileStorage{location: @stream_output_dir, socket: "socket"}
  end
end
