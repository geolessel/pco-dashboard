# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :dashboard,
  ecto_repos: [Dashboard.Repo]

config :dashboard_web,
  ecto_repos: [Dashboard.Repo],
  generators: [context_app: :dashboard]

# Configures the endpoint
config :dashboard_web, DashboardWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "c504NnmNskstt8XEE14yZvyOYu/WNwMW1HO7EZwo2YDtXCvgaGdT5wRr76gwWbQm",
  render_errors: [view: DashboardWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Dashboard.PubSub,
  live_view: [signing_salt: "lwk8WTXs"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :dashboard,
  api_base: "api.planningcenteronline.com",
  api_transport: :https,
  api_port: 443,
  # or :personal_access_token
  auth_type: :oauth,
  oauth_client_id: System.get_env("DASHBOARD_CLIENT_ID", "YOUR CLIENT ID"),
  oauth_client_secret: System.get_env("DASHBOARD_CLIENT_SECRET", "YOUR CLIENT SECRET"),
  oauth_callback_url: System.get_env("DASHBOARD_CALLBACK_URL", "YOUR CALLBACK URL")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
