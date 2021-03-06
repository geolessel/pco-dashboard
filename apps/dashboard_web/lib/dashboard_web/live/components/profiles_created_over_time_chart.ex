defmodule DashboardWeb.Components.ProfilesCreatedOverTimeChart do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :columns, [])}
  end

  @impl true
  def update(assigns, socket) do
    columns = Dashboard.Stores.get(data_module(), genserver_id(assigns), :columns)

    {:ok,
     socket
     |> assign(:columns, columns)
     |> assign(:title, "Profiles Created")
     |> assign(:product, :people)
     |> assign(:icon, "product_people-logomark")}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:columns, assigns.columns)

    DashboardWeb.LayoutView.render("chart-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "profiles_created_over_time_chart--user_#{assigns.user_id}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.ProfilesCreatedOverTimeChart
end
