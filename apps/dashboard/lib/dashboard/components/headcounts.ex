defmodule Dashboard.Components.Headcounts do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @impl true
  def data_sources do
    %{
      headcounts: "/check-ins/v2/headcounts"
    }
  end

  @impl true
  def process_data(%{headcounts: %Response{} = response} = state) do
    headcounts = Response.dig(response, [:body, "data"])

    total_count = Response.dig(response, [:body, "meta", "total_count"])

    state
    |> Map.put(:headcounts, headcounts)
    |> Map.put(:total_count, total_count)
  end
end
