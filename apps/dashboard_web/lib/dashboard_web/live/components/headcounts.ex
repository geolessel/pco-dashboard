defmodule DashboardWeb.Components.Headcounts do
  use DashboardWeb, :live_component

  alias Dashboard.Accounts

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :headcounts, [])}
  end

  @impl true
  def update(assigns, socket) do
    headcounts = Dashboard.Stores.ComponentStore.get({:global, get_id(assigns)}, "headcounts")

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

    # |> Map.put(:table_columns, [
    #   %{key: "kind", label: ""},
    #   %{key: "first_name", label: "First"},
    #   %{key: "last_name", label: "Last"},
    #   %{key: "medical_notes", label: "Medical Notes"}
    # ])

    DashboardWeb.LayoutView.render("number-card.html", assigns)
  end

  def get_id(assigns) do
    "headcounts--user_#{assigns.user_id}"
  end
end
