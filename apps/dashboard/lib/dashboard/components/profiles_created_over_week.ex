defmodule Dashboard.Components.ProfilesCreatedOverWeek do
  use Dashboard.Component

  def data_sources do
    today = Date.utc_today()

    %{
      this_7_days:
        "/people/v2/people?where[created_at][gt]=#{Date.add(today, -7)}&where[created_at][lte]=#{
          today
        }&fields[Person]=name&per_page=1",
      last_7_days:
        "/people/v2/people?where[created_at][gt]=#{Date.add(today, -14)}&where[created_at][lte]=#{
          Date.add(today, -7)
        }&fields[Person]=name&per_page=1"
    }
  end

  def process_data(
        %{this_7_days: this_7_days_response, last_7_days: last_7_days_response} = state
      ) do
    this_7_days =
      this_7_days_response
      |> Map.get(:body, %{})
      |> Map.get("meta")
      |> Map.get("total_count")

    last_7_days =
      last_7_days_response
      |> Map.get(:body, %{})
      |> Map.get("meta")
      |> Map.get("total_count")

    state
    |> Map.put(:this_7_days, this_7_days)
    |> Map.put(:last_7_days, last_7_days)
  end
end
