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
    module: "DashboardWeb.Components.PersonUpdated",
    name: "Recently Updated Profiles",
    refresh_type: "poll"
  },
  %{
    module: "DashboardWeb.Components.FormsOverview",
    name: "Forms Overview",
    refresh_type: "poll"
  },
  %{
    module: "DashboardWeb.Components.CheckIns",
    name: "Check-ins",
    refresh_type: "poll"
  },
  %{
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
    module: "DashboardWeb.Components.CheckInCount",
    name: "Total Check-ins",
    refresh_type: "poll"
  },
  %{
    module: "DashboardWeb.Components.Headcounts",
    name: "Headcounts",
    refresh_type: "poll"
  },
  %{
    module: "DashboardWeb.Components.ProfilesCreatedOverWeek",
    name: "Profiles Created",
    refresh_type: "poll"
  },
  %{
    module: "DashboardWeb.Components.ProfilesCreatedOverTimeChart",
    name: "Profiles Created Over Time Chart",
    refresh_type: "poll"
  },
  %{
    module: "DashboardWeb.Components.HeadcountsChart",
    name: "Headcounts Chart",
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
