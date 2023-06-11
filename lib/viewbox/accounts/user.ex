defmodule Viewbox.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:username, :string)
    field(:password, :string)
    field(:stream_key, :binary)

    timestamps()
  end

  @required_fields ~w(username password)a
  @optional_fields ~w()a
  @unique_fields ~w(username stream_key)a

  @doc false
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> put_password_hash()
    |> unique_constraint(@unique_fields)
  end

  def create_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> put_password_hash()
    |> unique_constraint(@unique_fields)
    |> generate_stream_key()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  defp generate_stream_key(changeset),
    do: put_change(changeset, :stream_key, Ecto.UUID.bingenerate())
end
