defmodule Viewbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias Membrane.RTMP.Source.TcpServer

  use Application

  @stream_port Application.compile_env(Viewbox, :stream_port, 9009)
  @stream_host Application.compile_env(Viewbox, :stream_host, {127, 0, 0, 1})

  @impl true
  def start(_type, _args) do
    tcp_server_options = %TcpServer{
      port: @stream_port,
      listen_options: [
        :binary,
        packet: :raw,
        active: false,
        ip: @stream_host
      ],
      socket_handler: fn socket ->
        IO.inspect(socket)
        Viewbox.Livestream.start_link(socket: socket)
      end
    }

    children = [
      %{id: TcpServer, start: {TcpServer, :start_link, [tcp_server_options]}},

      # Start the Telemetry supervisor
      ViewboxWeb.Telemetry,
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
