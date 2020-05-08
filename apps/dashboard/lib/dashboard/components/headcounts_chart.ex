defmodule Dashboard.Components.HeadcountsChart do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{
      headcounts:
        "/check-ins/v2/events/106369/attendance_types/18348/headcounts?include=event_time&per_page=100"
    }
  end

  @impl true
  def process_data(%{headcounts: headcounts} = state) do
    start_of_year = Date.from_erl!({2020, 1, 1})

    event_times =
      headcounts
      |> Map.get(:body, %{})
      |> Map.get("included")
      |> Enum.filter(fn event_time ->
        is_event_time = event_time |> Map.get("type") == "EventTime"

        {:ok, created_at, _tz_offset} =
          event_time |> Map.get("attributes") |> Map.get("shows_at") |> DateTime.from_iso8601()

        is_this_year =
          created_at
          |> DateTime.to_date()
          |> Date.compare(start_of_year)
          |> case do
            :lt -> false
            _gt_or_eq -> true
          end

        is_event_time && is_this_year
      end)
      |> Enum.map(&Map.get(&1, "id"))

    headcounts =
      headcounts
      |> Map.get(:body, %{})
      |> Map.get("data")
      |> Enum.filter(fn headcount ->
        event_time_id =
          headcount
          |> Map.get("relationships")
          |> Map.get("event_time")
          |> Map.get("data")
          |> Map.get("id")

        Enum.any?(event_times, fn x -> x == event_time_id end)
      end)
      |> Enum.map(fn headcount ->
        headcount |> Map.get("attributes") |> Map.get("total")
      end)

    state
    |> Map.put(:columns, [["Attendance" | headcounts]])
  end
end
