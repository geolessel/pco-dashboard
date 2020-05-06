defmodule DashboardWeb.Components.HeadcountsChart do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :headcounts_chart, [])}
  end

  @impl true
  def update(assigns, socket) do
    headcounts = Dashboard.Stores.get(data_module(), genserver_id(assigns), :headcounts)

    {:ok, assign(socket, :headcounts, headcounts)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Headcounts")
      |> Map.put(:product, :checkins)
      |> Map.put(:data_key, :headcounts)

    DashboardWeb.LayoutView.render("chart-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "headcounts_chart--user_#{assigns.user_id}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.HeadcountsChart
end
