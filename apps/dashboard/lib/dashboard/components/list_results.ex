defmodule Dashboard.Components.ListResults do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{
      results: "/people/v2/lists/${list_id}/people?per_page=8&order=-created_at"
    }
  end

  @impl true
  def process_data(%{results: %Dashboard.PlanningCenterApi.Response{} = response} = state) do
    results =
      response
      |> Map.get(:body, %{})
      |> Map.get("data")

    state
    |> Map.put(:results, results)
  end
end
