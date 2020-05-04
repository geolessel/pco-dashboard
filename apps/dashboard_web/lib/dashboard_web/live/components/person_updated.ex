defmodule DashboardWeb.Components.PersonUpdated do
  use DashboardWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :people, [])}
  end

  @impl true
  def update(assigns, socket) do
    people = Dashboard.Stores.get(get_id(assigns), "people")

    {:ok, assign(socket, :people, people)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Last Updated")
      |> Map.put(:product, :people)
      |> Map.put(:table_key, :people)
      |> Map.put(:table_columns, [
        %{key: "name", label: "Name"},
        %{key: "updated_at", label: "Updated"}
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  def get_id(assigns, configs \\ []) do
    "person_updated--user_#{assigns.user_id}"
  end
end
