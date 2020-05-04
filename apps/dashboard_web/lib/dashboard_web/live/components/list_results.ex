defmodule DashboardWeb.Components.ListResults do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :results, [])}
  end

  @impl true
  def update(assigns, socket) do
    results = Dashboard.Stores.get(genserver_id(assigns, assigns.dashboard_component), "results")

    {:ok, assign(socket, :results, results)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "List Results - LIST NAME HERE")
      |> Map.put(:product, :people)
      |> Map.put(:table_key, :results)
      |> Map.put(:table_columns, [
        %{key: "name", label: "Name"},
        %{key: "created_at", label: "Created"}
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    suffix = Dashboard.Dashboards.DashboardComponent.genserver_name_suffix(dc)

    "list_results--user_#{assigns.user_id}#{suffix}"
  end
end
