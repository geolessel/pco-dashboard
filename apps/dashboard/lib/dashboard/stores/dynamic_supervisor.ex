defmodule Dashboard.Stores.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(args \\ []) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_child(name, component, user) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Dashboard.Stores.ComponentStore, name: {:global, name}, component: component, user: user}
    )
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
