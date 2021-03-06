defmodule DashboardWeb.Components.FormSubmissions do
  use DashboardWeb, :live_component
  @behaviour DashboardWeb.Behaviours.ComponentLiveView

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :submissions, [])}
  end

  @impl true
  def update(assigns, socket) do
    id = genserver_id(assigns, assigns.dashboard_component)
    submissions = Dashboard.Stores.get(data_module(), id, :submissions, [])
    form_name = Dashboard.Stores.get(data_module(), id, :form_name)
    last_update = Dashboard.Stores.get(data_module(), id, :last_update)
    included = Dashboard.Stores.get(data_module(), id, :included, [])

    {:ok,
     socket
     |> assign(:submissions, submissions)
     |> assign(:genserver_id, id)
     |> assign(:last_update, last_update)
     |> assign(:included, included)
     |> assign(:title, "Form Submissions - #{form_name}")
     |> assign(:product, :people)
     |> assign(:icon, "product_people-logomark")
     |> assign(:table_key, :submissions)}
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> Map.put(:table_columns, [
        %{
          get_value: fn item ->
            person_id = item["relationships"]["person"]["data"]["id"]

            person =
              assigns.included
              |> Enum.find(fn include ->
                include["type"] == "Person" && include["id"] == person_id
              end)

            person["attributes"]["name"]
          end,
          label: "Name"
        },
        %{
          label: "Submitted",
          get_value: fn item ->
            {:ok, datetime, 0} = DateTime.from_iso8601(item["attributes"]["created_at"])
            Timex.from_now(datetime)
          end
        }
      ])

    DashboardWeb.LayoutView.render("table-card.html", assigns)
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def genserver_id(assigns, dc \\ %Dashboard.Dashboards.DashboardComponent{}) do
    suffix = Dashboard.Dashboards.DashboardComponent.genserver_name_suffix(dc)

    "form_submissions--user_#{assigns.user_id}#{suffix}"
  end

  @impl DashboardWeb.Behaviours.ComponentLiveView
  def data_module, do: Dashboard.Components.FormSubmissions
end
