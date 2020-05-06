defmodule Dashboard.Components.HeadcountsChart do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{
      headcounts: "/check-ins/v2/headcounts?order=-created_at"
    }
  end

  @impl true
  def process_data(%{headcounts: %Dashboard.PlanningCenterApi.Response{} = response} = state) do
    headcounts =
      response
      |> Map.get(:body, %{})
      |> Map.get("data")

    Map.put(state, :headcounts, headcounts)
  end
end
