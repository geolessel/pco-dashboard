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
    api_path: "/people/v2/people?order=-updated_at&per_page=5&fields[Person]=name,updated_at",
    assign: "people",
    module: "Dashboard.Components.PersonUpdated",
    name: "Recently Updated Profiles",
    refresh_type: "poll"
  }
]

components
|> Enum.each(fn attrs ->
  IO.puts("  - #{attrs.name}")

  case Repo.get_by(Component, attrs) do
    nil -> %Component{}
    c -> c
  end
  |> Dashboards.change_component(attrs)
  |> Repo.insert_or_update!()
end)
