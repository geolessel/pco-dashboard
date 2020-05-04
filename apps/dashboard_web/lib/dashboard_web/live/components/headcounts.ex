defmodule DashboardWeb.Components.Headcounts do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :headcounts, [])}
  end

  @impl true
  def update(assigns, socket) do
    headcounts = Dashboard.Stores.get(genserver_id(assigns), "headcounts")

    {:ok, assign(socket, :headcounts, headcounts)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Headcounts")
      |> Map.put(:product, :checkins)
      |> Map.put(:grid_width, 1)
      |> Map.put(:data_key, :headcounts)
      |> Map.put(:data_number, length(assigns.headcounts))

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "headcounts--user_#{assigns.user_id}"
  end
end
