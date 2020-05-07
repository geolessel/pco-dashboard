defmodule Dashboard.Components.FormsOverview do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @impl true
  def data_sources do
    %{
      forms: "/people/v2/forms?order=-created_at&per_page=8&fields[Form]=name,submission_count"
    }
  end

  @impl true
  def process_data(%{forms: %Response{} = response} = state) do
    forms = Response.dig(response, [:body, "data"])

    state
    |> Map.put(:forms, forms)
  end
end
