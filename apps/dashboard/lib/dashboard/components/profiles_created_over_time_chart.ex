defmodule Dashboard.Components.ProfilesCreatedOverTimeChart do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @fetch_days_range 0..-6

  @impl true
  def data_sources do
    today = Date.utc_today()

    @fetch_days_range
    |> Enum.reduce(%{}, fn add_amount, sources ->
      sources
      |> Map.put(
        "today#{add_amount}",
        "/people/v2/people?where[created_at][gt]=#{Date.add(today, add_amount)}&where[created_at][lte]=#{
          Date.add(today, add_amount + 1)
        }&fields[Person]=grade&per_page=1"
      )
    end)
  end

  @impl true
  def process_data(state) do
    # results in a list of counts with today last
    columns =
      @fetch_days_range
      |> Enum.reduce([], fn add_amount, list ->
        count = total_count(Map.get(state, "today#{add_amount}"))
        [count | list]
      end)
      |> List.insert_at(0, "Profiles Created")

    state
    |> Map.put(:columns, [columns])
  end

  defp total_count(%{body: body} = _response) do
    Response.dig(body, ["meta", "total_count"])
  end
end
