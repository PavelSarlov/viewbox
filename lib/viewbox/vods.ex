defmodule Viewbox.Vods do
  @moduledoc """
  The Vods context.
  """

  import Ecto.Query, warn: false
  alias Viewbox.Repo

  alias Viewbox.Vods.Vod

  @stream_output_dir Application.compile_env(:viewbox, :stream_output_dir, "output")
  @stream_live_dir Application.compile_env(:viewbox, :stream_live_dir, "live")
  @stream_live_file Application.compile_env(:viewbox, :stream_live_file, "live.m3u8")

  @doc """
  Returns the list of vods.

  ## Examples

      iex> list_vods()
      [%Vod{}, ...]

  """
  def list_vods(preload \\ []) do
    Repo.all(Vod) |> Repo.preload(preload)
  end

  @doc """
  Gets a single vod.

  Raises `Ecto.NoResultsError` if the Vod does not exist.

  ## Examples

      iex> get_vod!(123)
      %Vod{}

      iex> get_vod!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vod!(id, preload \\ []), do: Repo.get!(Vod, id) |> Repo.preload(preload)

  @doc """
  Creates a vod.

  ## Examples

      iex> create_vod(%{field: value})
      {:ok, %Vod{}}

      iex> create_vod(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vod(attrs \\ %{}) do
    result =
      %Vod{}
      |> Vod.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:user, attrs.user)
      |> Repo.insert(returning: true)

    case result do
      {:ok, vod} ->
        [@stream_output_dir, Integer.to_string(vod.user_id), @stream_live_dir, @stream_live_file]
        |> Path.join()
        |> Path.expand()
        |> File.rm()

        from =
          [@stream_output_dir, Integer.to_string(vod.user_id), @stream_live_dir]
          |> Path.join()
          |> Path.expand()

        to =
          [@stream_output_dir, Integer.to_string(vod.user_id), Integer.to_string(vod.id)]
          |> Path.join()
          |> Path.expand()

        File.rename(from, to)

      _ ->
        nil
    end

    result
  end

  @doc """
  Updates a vod.

  ## Examples

      iex> update_vod(vod, %{field: new_value})
      {:ok, %Vod{}}

      iex> update_vod(vod, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vod(%Vod{} = vod, attrs) do
    vod
    |> Vod.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vod.

  ## Examples

      iex> delete_vod(vod)
      {:ok, %Vod{}}

      iex> delete_vod(vod)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vod(%Vod{} = vod) do
    Repo.delete(vod)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vod changes.

  ## Examples

      iex> change_vod(vod)
      %Ecto.Changeset{data: %Vod{}}

  """
  def change_vod(%Vod{} = vod, attrs \\ %{}) do
    Vod.changeset(vod, attrs)
  end
end
