defmodule Dashboard.Components.Headcounts do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{
      headcounts: "/check-ins/v2/headcounts"
    }
  end

  @impl true
  def process_data(%{headcounts: %Dashboard.PlanningCenterApi.Response{} = response} = state) do
    headcounts =
      response
      |> Map.get(:body, %{})
      |> Map.get("data")

    total_count =
      response
      |> Map.get(:body, %{})
      |> Map.get("meta")
      |> Map.get("total_count")

    state
    |> Map.put(:headcounts, headcounts)
    |> Map.put(:total_count, total_count)
  end
end
