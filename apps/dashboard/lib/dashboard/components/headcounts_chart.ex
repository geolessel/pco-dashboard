defmodule Dashboard.Components.HeadcountsChart do
  use Dashboard.Component

  @impl true
  def data_sources do
    # NOTE: For testing purposes, these are known working IDs for Carlsbad Org
    # event_id: 106369, attendance_type_id: 18348
    %{
      headcounts:
        "/check-ins/v2/events/${event_id}/attendance_types/${attendance_type_id}/headcounts?include=event_time&per_page=100"
    }
  end

  @impl true
  def process_data(%{headcounts: headcounts} = state) do
    start_of_dst = Date.from_erl!({2020, 3, 8})

    event_times =
      headcounts
      |> Map.get(:body, %{})
      |> Map.get("included")
      |> Enum.filter(fn event_time ->
        is_event_time = event_time |> Map.get("type") == "EventTime"

        {:ok, created_at, _tz_offset} =
          event_time |> Map.get("attributes") |> Map.get("shows_at") |> DateTime.from_iso8601()

        is_this_year_and_dst =
          created_at
          |> DateTime.to_date()
          |> Date.compare(start_of_dst)
          |> case do
            :lt -> false
            _gt_or_eq -> true
          end

        is_event_time && is_this_year_and_dst
      end)
      # |> Enum.map(&Map.get(&1, "id"))
      |> Enum.map(fn x ->
        Map.get(x, "shows_at")

        {:ok, shows_at, _tz_offset} =
          x |> Map.get("attributes") |> Map.get("shows_at") |> DateTime.from_iso8601()

        %{
          date: DateTime.to_date(shows_at),
          id: Map.get(x, "id"),
          time: DateTime.to_time(shows_at)
        }
      end)

    columns =
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

        Enum.any?(event_times, fn x -> x.id == event_time_id end)
      end)
      |> Enum.map(fn headcount ->
        headcount |> Map.get("attributes") |> Map.get("total")
      end)

    IO.puts("COLUMNS")
    IO.inspect(columns)

    headcounts_grouped =
      headcounts
      |> Map.get(:body, %{})
      |> Map.get("data")
      |> Enum.filter(
        # filter by event_times that are in the current year
        &Enum.any?(event_times, fn x ->
          x.id == &1["relationships"]["event_time"]["data"]["id"]
        end)
      )
      |> Enum.map(fn x ->
        event_time_id = x["relationships"]["event_time"]["data"]["id"]
        total = x["attributes"]["total"]

        time =
          event_times
          |> Enum.find(fn et ->
            et.id == event_time_id
          end)
          |> Map.get(:time)

        date =
          event_times
          |> Enum.find(fn et ->
            et.id == event_time_id
          end)
          |> Map.get(:date)

        %{
          date: date,
          time: time,
          total: total
        }
      end)
      |> Enum.sort(&(Date.compare(&1.date, &2.date) == :lt))
      |> Enum.group_by(fn x -> x.time end)
      |> Enum.map(fn {k, v} ->
        totals = v |> Enum.map(& &1.total)

        [Time.to_string(k) | totals]
      end)

    state
    |> Map.put(:columns, headcounts_grouped)

    # |> Map.put(:columns, ["Attendance" | [columns]])

    # TODO: Allow passing additional information to DATA in renderC3Chart.js
    # so we can have data groups, set chart types, etc.
    # Example:
    #   data: {
    #     columns: ...,
    #     groups: [["9:30am", "11:00am"]],
    #     type: "bar",
    #   }
  end
end
