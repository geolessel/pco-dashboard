defmodule Dashboard.Components.PersonUpdated do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{people: "/people/v2/people?order=-updated_at&per_page=8&fields[Person]=name,updated_at"}
  end

  @impl true
  def process_data(%{people: %Dashboard.PlanningCenterApi.Response{} = people_response} = state) do
    people =
      people_response
      |> Map.get(:body, %{})
      |> Map.get("data")

    Map.put(state, :people, people)
  end
end
