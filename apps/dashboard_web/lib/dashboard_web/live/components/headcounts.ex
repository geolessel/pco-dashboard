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
    headcounts = Dashboard.Stores.get(id, "headcounts")

    {:ok, socket |> assign(:headcounts, headcounts) |> assign(:genserver_id, id)}
  end

  @impl true
  def render(assigns) do
    response = Dashboard.Stores.get(assigns.genserver_id, :last_response)

    total_count = response["meta"]["total_count"]

    assigns =
      assigns
      |> Map.put(:title, "Headcounts")
      |> Map.put(:product, :checkins)
      |> Map.put(:grid_width, 1)
      |> Map.put(:data_key, :headcounts)
      |> Map.put(:data_number, total_count)

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    suffix = Dashboard.Dashboards.DashboardComponent.genserver_name_suffix(dc)

    "headcounts--user_#{assigns.user_id}#{suffix}"
  end
end
