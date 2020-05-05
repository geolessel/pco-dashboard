defmodule DashboardWeb.Components.PersonUpdated do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :people, [])}
  end

  @impl true
  def update(assigns, socket) do
    people = Dashboard.Stores.get(data_module(), genserver_id(assigns), :people)

    {:ok, assign(socket, :people, people)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:title, "Recently Updated")
      |> Map.put(:product, :people)
      |> Map.put(:table_key, :people)
      |> Map.put(:table_columns, [
        %{key: "name", label: "Name"},
        %{
          get_value: fn col ->
            {:ok, datetime, 0} = DateTime.from_iso8601(col["attributes"]["updated_at"])
            Timex.from_now(datetime)
          end,
          label: "Updated"
        }
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, _dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    "person_updated--user_#{assigns.user_id}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.PersonUpdated
end
