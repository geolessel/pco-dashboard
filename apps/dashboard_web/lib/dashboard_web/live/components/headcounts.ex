defmodule DashboardWeb.Components.Headcounts do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :headcounts, [])}
  end

  @impl true
  def update(assigns, socket) do
    id = genserver_id(assigns, assigns.dashboard_component)

    %{headcounts: headcounts, total_count: total_count} =
      Dashboard.Stores.get_all(data_module(), id)

    {:ok,
     socket
     |> assign(:headcounts, headcounts)
     |> assign(:total_count, total_count)
     |> assign(:title, "Headcounts")
     |> assign(:product, :checkins)
     |> assign(:icon, "product_check-ins-logomark")
     |> assign(:grid_width, 1)
     |> assign(:timeframe, "This week")}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:data_number, assigns.total_count)
      |> Map.put(:comparison_number, 800)

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "headcounts--user_#{assigns.user_id}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.Headcounts
end
