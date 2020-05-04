defmodule DashboardWeb.Components.FormsOverview do
  use DashboardWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :forms, [])}
  end

  @impl true
  def update(assigns, socket) do
    forms = Dashboard.Stores.get(get_id(assigns), "forms")

    {:ok, assign(socket, :forms, forms)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Form Overview")
      |> Map.put(:product, :people)
      |> Map.put(:table_key, :forms)
      |> Map.put(:table_columns, [
        %{key: "name", label: "Form"},
        %{key: "submission_count", label: "Submissions"},
        %{key: "unknown", label: "Latest"}
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  def get_id(assigns, configs \\ []) do
    "forms_overview--user_#{assigns.user_id}"
  end
end
