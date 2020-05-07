defmodule Dashboard.Components.PersonUpdated do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @impl true
  def data_sources do
    %{people: "/people/v2/people?order=-updated_at&per_page=8&fields[Person]=name,updated_at"}
  end

  @impl true
  def process_data(%{people: %Response{} = people_response} = state) do
    people = Response.dig(people_response, [:body, "data"])

    Map.put(state, :people, people)
  end
end
