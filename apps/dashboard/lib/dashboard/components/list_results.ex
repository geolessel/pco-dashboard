defmodule Dashboard.Components.ListResults do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @impl true
  def data_sources do
    %{
      results: "/people/v2/lists/${list_id}/people?per_page=8&order=-created_at"
    }
  end

  @impl true
  def process_data(%{results: %Response{} = response} = state) do
    results = Response.dig(response, [:body, "data"])

    state
    |> Map.put(:results, results)
  end
end
