defmodule Dashboard.Components.ListResults do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @impl true
  def data_sources do
    %{
      results: "/people/v2/lists/${list_id}/people?per_page=8&order=-created_at",
      list: "/people/v2/lists/${list_id}&fields[List]=name,description"
    }
  end

  @impl true
  def process_data(%{results: %Response{} = response, list: %Response{} = list_response} = state) do
    results = Response.dig(response, [:body, "data"])

    list_attributes = Response.dig(list_response, [:body, "data", "attributes"])

    list_name =
      case list_attributes["name"] do
        nil -> list_attributes["description"]
        name -> name
      end

    state
    |> Map.put(:results, results)
    |> Map.put(:list_name, list_name)
  end
end
