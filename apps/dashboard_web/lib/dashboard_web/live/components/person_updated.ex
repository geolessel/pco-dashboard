defmodule DashboardWeb.Components.PersonUpdated do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :people, [])}
  end

  @impl true
  def update(assigns, socket) do
    people = Dashboard.Stores.get(data_module(), genserver_id(assigns), :people, [])
    last_update = Dashboard.Stores.get(data_module(), genserver_id(assigns), :last_update)

    {:ok,
     socket
     |> assign(:people, people)
     |> assign(:last_update, last_update)
     |> assign(:title, "Recently Updated")
     |> assign(:product, :people)
     |> assign(:icon, "product_people-logomark")
     |> assign(:table_key, :people)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
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
