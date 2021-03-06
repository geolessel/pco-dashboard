defmodule DashboardWeb.Components.CheckInCount do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :check_in_count, [])}
  end

  @impl true
  def update(assigns, socket) do
    id = genserver_id(assigns, assigns.dashboard_component)
    check_in_count = Dashboard.Stores.get(data_module(), id, :check_in_count)

    {:ok,
     socket
     |> assign(:check_in_count, check_in_count)
     |> assign(:genserver_id, id)
     |> assign(:title, "Check-ins")
     |> assign(:product, :checkins)
     |> assign(:icon, "product_check-ins-logomark")
     |> assign(:grid_width, 1)
     |> assign(:timeframe, "This week")}
  end

  @impl true
  def render(assigns) do
    total_count = Dashboard.Stores.get(data_module(), assigns.genserver_id, :total_count)

    assigns =
      assigns
      |> Map.put(:data_number, total_count)
      |> Map.put(:comparison_number, 800)

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "check_in_count--user_#{assigns.user_id}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.CheckInCount
end
