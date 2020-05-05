defmodule Dashboard.Components.FormsOverview do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{
      forms: "/people/v2/forms?order=-created_at&per_page=8&fields[Form]=name,submission_count"
    }
  end

  @impl true
  def process_data(%{forms: %Dashboard.PlanningCenterApi.Response{} = response} = state) do
    forms =
      response
      |> Map.get(:body, %{})
      |> Map.get("data")

    state
    |> Map.put(:forms, forms)
  end
end
