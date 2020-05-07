defmodule Dashboard.Components.CheckInCount do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @impl true
  def data_sources do
    %{
      check_in_count:
        "/check-ins/v2/check_ins?per_page=1&order=updated_at&where[created_at][gte]=2020-05-02"
    }
  end

  @impl true
  def process_data(%{check_in_count: %Response{} = check_in_count_response} = state) do
    check_in_count = Response.dig(check_in_count_response, [:body, "data"])

    total_count = Response.dig(check_in_count_response, [:body, "meta", "total_count"])

    state
    |> Map.put(:check_in_count, check_in_count)
    |> Map.put(:total_count, total_count)
  end
end
