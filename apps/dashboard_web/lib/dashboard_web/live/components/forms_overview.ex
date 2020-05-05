defmodule DashboardWeb.Components.FormsOverview do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :forms, [])}
  end

  @impl true
  def update(assigns, socket) do
    forms = Dashboard.Stores.get(data_module(), genserver_id(assigns), :forms, [])

    {:ok, assign(socket, :forms, forms)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Form Overview")
      |> Map.put(:product, :people)
      |> Map.put(:table_key, :forms)
      |> Map.put(:grid_height, 4)
      |> Map.put(:table_columns, [
        %{key: "name", label: "Form"},
        %{key: "submission_count", label: "Submissions"},
        %{key: "unknown", label: "Latest"}
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "forms_overview--user_#{assigns.user_id}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.FormsOverview
end
