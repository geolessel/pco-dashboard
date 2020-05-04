# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Dashboard.Repo.insert!(%Dashboard.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Dashboard.Repo
alias Dashboard.Components
alias Dashboard.Components.Configuration
alias Dashboard.Dashboards
alias Dashboard.Dashboards.Component

IO.puts("Seeding dashboard components...")

components = [
  %{
    api_path: "/people/v2/people?order=-updated_at&per_page=8&fields[Person]=name,updated_at",
    assign: "people",
    module: "DashboardWeb.Components.PersonUpdated",
    name: "Recently Updated Profiles",
    refresh_type: "poll"
  },
  %{
    api_path: "/people/v2/forms?order=-created_at&per_page=8&fields[Form]=name,submission_count",
    assign: "forms",
    module: "DashboardWeb.Components.FormsOverview",
    name: "Forms Overview",
    refresh_type: "poll"
  },
  %{
    api_path:
      "/check-ins/v2/check_ins?order=-updated_at&per_page=8&fields[CheckIn]=first_name,last_name,kind,medical_notes",
    assign: "checkins",
    module: "DashboardWeb.Components.CheckIns",
    name: "Check-ins",
    refresh_type: "poll"
  },
  %{
    api_path: "/people/v2/lists/${list_id}/people?per_page=8&order=-created_at",
    assign: "results",
    configurations: [
      %{
        name: "list_id",
        label: "List ID"
      }
    ],
    module: "DashboardWeb.Components.ListResults",
    name: "List Results",
    refresh_type: "poll"
  },
  %{
    api_path:
      "/people/v2/forms/${form_id}/form_submissions?include=person&per_page=8&order=-created_at",
    assign: "submissions",
    configurations: [
      %{
        name: "form_id",
        label: "Form ID"
      }
    ],
    module: "DashboardWeb.Components.FormSubmissions",
    name: "Form Submissions",
    refresh_type: "poll"
  },
  %{
    api_path: "/check-ins/v2/check_ins?order=updated_at&filter=regular&per_page=500&offset=4850",
    assign: "check_in_count",
    module: "DashboardWeb.Components.CheckInCount",
    name: "Total Check-ins",
    refresh_type: "poll"
  },
  %{
    api_path: "/check-ins/v2/headcounts",
    assign: "headcounts",
    module: "DashboardWeb.Components.Headcounts",
    name: "Headcounts",
    refresh_type: "poll"
  }
]

components
|> Enum.each(fn attrs ->
  IO.puts("  - #{attrs.name}")

  component =
    case Repo.get_by(Component, %{name: attrs.name}) do
      nil -> %Component{}
      c -> c
    end
    |> Dashboards.change_component(attrs)
    |> Repo.insert_or_update!()

  attrs
  |> Map.get(:configurations, [])
  |> Enum.each(fn attrs ->
    attrs = Map.put(attrs, :component_id, component.id)

    config =
      case Repo.get_by(Configuration, attrs) do
        nil -> %Configuration{}
        c -> c
      end
      |> Components.change_configuration(attrs)
      |> Repo.insert_or_update!()
  end)
end)
