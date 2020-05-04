defmodule DashboardWeb.Components.CheckInCount do
  use DashboardWeb, :live_component

  alias Dashboard.Accounts

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :check_in_count, [])}
  end

  @impl true
  def update(assigns, socket) do
    check_in_count =
      Dashboard.Stores.ComponentStore.get({:global, get_id(assigns)}, "check_in_count")

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

    # |> Map.put(:table_columns, [
    #   %{key: "kind", label: ""},
    #   %{key: "first_name", label: "First"},
    #   %{key: "last_name", label: "Last"},
    #   %{key: "medical_notes", label: "Medical Notes"}
    # ])

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  def get_id(assigns) do
    "check_in_count--user_#{assigns.user_id}"
  end
end
