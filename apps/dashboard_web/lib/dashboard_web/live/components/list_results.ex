defmodule DashboardWeb.Components.ListResults do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :results, [])}
  end

  @impl true
  def update(assigns, socket) do
    results =
      Dashboard.Stores.get(
        data_module(),
        genserver_id(assigns, assigns.dashboard_component),
        :results,
        []
      )

    list_name =
      Dashboard.Stores.get(
        data_module(),
        genserver_id(assigns, assigns.dashboard_component),
        :list_name,
        ""
      )

    {:ok,
     socket
     |> assign(:results, results)
     |> assign(:title, "List Results - #{list_name}")
     |> assign(:product, :people)
     |> assign(:icon, "product_people-logomark")
     |> assign(:list_name, list_name)
     |> assign(:table_key, :results)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:table_columns, [
        %{key: "name", label: "Name"}
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    suffix = Dashboard.Dashboards.DashboardComponent.genserver_name_suffix(dc)

    "list_results--user_#{assigns.user_id}#{suffix}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.ListResults
end
