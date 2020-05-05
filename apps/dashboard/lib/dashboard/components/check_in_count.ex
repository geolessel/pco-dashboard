defmodule Dashboard.Components.CheckInCount do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{
      check_in_count: "/check-ins/v2/check_ins?order=updated_at&where[created_at][gte]=2020-05-02"
    }
  end

  @impl true
  def process_data(
        %{check_in_count: %Dashboard.PlanningCenterApi.Response{} = check_in_count_response} =
          state
      ) do
    check_in_count =
      check_in_count_response
      |> Map.get(:body, %{})
      |> Map.get("data")

    total_count =
      check_in_count_response
      |> Map.get(:body, %{})
      |> Map.get("meta")
      |> Map.get("total_count")

    state
    |> Map.put(:check_in_count, check_in_count)
    |> Map.put(:total_count, total_count)
  end
end
