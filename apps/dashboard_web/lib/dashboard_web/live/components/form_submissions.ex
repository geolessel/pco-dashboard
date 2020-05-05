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

    {:ok, socket |> assign(:submissions, submissions) |> assign(:genserver_id, id)}
  end

  @impl true
  def render(assigns) do
    included = Dashboard.Stores.get(data_module(), assigns.genserver_id, :included)

    assigns =
      assigns
      |> Map.put(:title, "Form Submissions - FORM NAME HERE")
      |> Map.put(:product, :people)
      |> Map.put(:table_key, :submissions)
      |> Map.put(:table_columns, [
        %{
          get_value: fn item ->
            person_id = item["relationships"]["person"]["data"]["id"]

            person =
              included
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
