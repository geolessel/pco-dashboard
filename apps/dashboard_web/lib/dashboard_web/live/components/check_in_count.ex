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
    check_in_count = Dashboard.Stores.get(id, "check_in_count")

    {:ok, socket |> assign(:check_in_count, check_in_count) |> assign(:genserver_id, id)}
  end

  @impl true
  def render(assigns) do
    response = Dashboard.Stores.get(assigns.genserver_id, :last_response)

    total_count = response["meta"]["total_count"]

    assigns =
      assigns
      |> Map.put(:title, "Check-ins")
      |> Map.put(:product, :checkins)
      |> Map.put(:grid_width, 1)
      |> Map.put(:data_key, :check_in_count)
      |> Map.put(:data_number, total_count)

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    suffix = Dashboard.Dashboards.DashboardComponent.genserver_name_suffix(dc)

    "check_in_count--user_#{assigns.user_id}#{suffix}"
  end
end
