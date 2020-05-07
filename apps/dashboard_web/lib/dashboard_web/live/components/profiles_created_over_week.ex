defmodule DashboardWeb.Components.ProfilesCreatedOverWeek do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:this_7_days, 0)
     |> assign(:last_7_days, 0)}
  end

  @impl true
  def update(assigns, socket) do
    id = genserver_id(assigns, assigns.dashboard_component)

    %{this_7_days: this_7_days, last_7_days: last_7_days} =
      Dashboard.Stores.get_all(data_module(), id)

    {:ok,
     socket
     |> assign(:this_7_days, this_7_days)
     |> assign(:last_7_days, last_7_days)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Profiles Created")
      |> Map.put(:product, :people)
      |> Map.put(:grid_width, 1)
      |> Map.put(:data_number, assigns.this_7_days)
      |> Map.put(:icon, "product_people-logomark")
      |> Map.put(:timeframe, "Last 7 days")
      |> Map.put(:comparison_number, assigns.last_7_days)

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "profiles_created_over_week--user_#{assigns.user_id}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.ProfilesCreatedOverWeek
end
