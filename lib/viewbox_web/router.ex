defmodule ViewboxWeb.Router do
  use ViewboxWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {ViewboxWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ViewboxWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/live/:username", LivestreamController, :index)

    # users
    get("/users", UserController, :index)
    get("/users/:username", UserController, :show)
    get("/register", UserController, :new)
    post("/users", UserController, :create)
  end

  # Other scopes may use custom stacks.
  scope "/api", ViewboxWeb do
    pipe_through(:api)

    get("/stream/:username", LivestreamController, :stream)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:viewbox, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: ViewboxWeb.Telemetry)
    end
  end
end
