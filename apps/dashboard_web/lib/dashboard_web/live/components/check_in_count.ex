defmodule DashboardWeb.Components.CheckInCount do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :check_in_count, [])}
  end

  @impl true
  def update(assigns, socket) do
    check_in_count = Dashboard.Stores.get(genserver_id(assigns), "check_in_count")

    {:ok, assign(socket, :check_in_count, check_in_count)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Check-ins")
      |> Map.put(:product, :checkins)
      |> Map.put(:grid_width, 1)
      |> Map.put(:data_key, :check_in_count)
      |> Map.put(:data_number, length(assigns.check_in_count))

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "check_in_count--user_#{assigns.user_id}"
  end
end
