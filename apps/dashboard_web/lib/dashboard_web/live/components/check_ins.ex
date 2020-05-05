defmodule DashboardWeb.Components.CheckIns do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :checkins, [])}
  end

  @impl true
  def update(assigns, socket) do
    checkins = Dashboard.Stores.get(data_module(), genserver_id(assigns), :checkins, [])

    {:ok, assign(socket, :checkins, checkins)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Check-ins")
      |> Map.put(:product, :checkins)
      |> Map.put(:table_key, :checkins)
      |> Map.put(:grid_width, 3)
      |> Map.put(:table_columns, [
        %{key: "kind", label: ""},
        %{key: "first_name", label: "First"},
        %{key: "last_name", label: "Last"},
        %{key: "medical_notes", label: "Medical Notes"}
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "checkins--user_#{assigns.user_id}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.CheckIns
end
