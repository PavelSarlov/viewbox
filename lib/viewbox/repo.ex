defmodule Viewbox.Repo do
  use Ecto.Repo,
    otp_app: :viewbox,
    adapter: Ecto.Adapters.Postgres
end
