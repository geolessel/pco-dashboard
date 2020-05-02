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
  }
]

components
|> Enum.each(fn attrs ->
  IO.puts("  - #{attrs.name}")

  case Repo.get_by(Component, %{name: attrs.name}) do
    nil -> %Component{}
    c -> c
  end
  |> Dashboards.change_component(attrs)
  |> Repo.insert_or_update!()
end)
