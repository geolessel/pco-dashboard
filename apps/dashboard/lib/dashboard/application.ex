defmodule Dashboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Dashboard.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Dashboard.PubSub},
      # Start a worker by calling: Dashboard.Worker.start_link(arg)
      # {Dashboard.Worker, arg}
      {DynamicSupervisor, strategy: :one_for_one, name: Dashboard.Stores.DynamicSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Dashboard.Supervisor)
  end
end
