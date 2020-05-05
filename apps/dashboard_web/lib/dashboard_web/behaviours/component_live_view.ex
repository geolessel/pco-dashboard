defmodule DashboardWeb.Behaviours.ComponentLiveView do
  @callback genserver_id(assigns :: Map.t(), dashboard_component :: Dashboard.Dashboards.DashboardComponent.t()) :: String.t()

  @callback data_module() :: atom()
end
