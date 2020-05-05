defmodule DashboardWeb.Components.HeadcountsChart do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :headcounts_chart, [])}
  end

  @impl true
  def update(assigns, socket) do
    headcounts_chart = Dashboard.Stores.get(genserver_id(assigns), "headcounts_chart")

    {:ok, assign(socket, :headcounts_chart, headcounts_chart)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Headcounts")
      |> Map.put(:product, :checkins)
      |> Map.put(:data_key, :headcounts_chart)

    DashboardWeb.LayoutView.render("chart-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "headcounts_chart--user_#{assigns.user_id}"
  end
end
