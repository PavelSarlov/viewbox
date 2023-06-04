defmodule Viewbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ViewboxWeb.Telemetry,
      # Start the Ecto repository
      Viewbox.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Viewbox.PubSub},
      # Start Finch
      {Finch, name: Viewbox.Finch},
      # Start the Endpoint (http/https)
      ViewboxWeb.Endpoint
      # Start a worker by calling: Viewbox.Worker.start_link(arg)
      # {Viewbox.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Viewbox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ViewboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
