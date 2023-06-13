defmodule Viewbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias Membrane.RTMP.Source.TcpServer

  use Application

  @port Application.compile_env(:viewbox, :stream_port, 4001)
  @host Application.compile_env(:viewbox, :stream_host, {127, 0, 0, 1})

  @impl true
  def start(_type, _args) do
    tcp_server_options = %TcpServer{
      port: @port,
      listen_options: [
        :binary,
        packet: :raw,
        active: false,
        ip: @host
      ],
      socket_handler: fn socket ->
        Agent.update(Viewbox.SocketAgent, fn old -> Enum.reverse([socket | Enum.reverse(old)]) end)

        Viewbox.LiveStream.start_link(socket: socket)
      end
    }

    children = [
      %{id: TcpServer, start: {TcpServer, :start_link, [tcp_server_options]}},
      %{
        id: Viewbox.SocketAgent,
        start: {Agent, :start_link, [fn -> [] end, [name: Viewbox.SocketAgent]]}
      },

      # Start the Telemetry supervisor
      ViewboxWeb.Telemetry,
      # Start the Ecto repository
      Viewbox.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Viewbox.PubSub},
      # Start the Endpoint (http/https)
      ViewboxWeb.Endpoint
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
