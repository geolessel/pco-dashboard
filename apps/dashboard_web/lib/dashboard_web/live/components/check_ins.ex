defmodule DashboardWeb.Components.CheckIns do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  alias Dashboard.Accounts

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :checkins, [])}
  end

  @impl true
  def update(assigns, socket) do
    checkins = Dashboard.Stores.get(genserver_id(assigns), "checkins")

    {:ok, assign(socket, :checkins, checkins)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Check-ins")
      |> Map.put(:product, :checkins)
      |> Map.put(:table_key, :checkins)
      |> Map.put(:grid_width, 5)
      |> Map.put(:table_columns, [
        %{key: "kind", label: ""},
        %{key: "first_name", label: "First"},
        %{key: "last_name", label: "Last"},
        %{key: "medical_notes", label: "Medical Notes"}
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "checkins--user_#{assigns.user_id}"
  end
end
