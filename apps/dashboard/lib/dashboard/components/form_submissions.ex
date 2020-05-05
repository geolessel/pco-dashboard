defmodule Dashboard.Components.FormSubmissions do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{
      submissions:
        "/people/v2/forms/${form_id}/form_submissions?include=person&per_page=8&order=-created_at"
    }
  end

  @impl true
  def process_data(%{submissions: %Dashboard.PlanningCenterApi.Response{} = response} = state) do
    submissions =
      response
      |> Map.get(:body, %{})
      |> Map.get("data")

    included =
      response
      |> Map.get(:body, %{})
      |> Map.get("included")

    state
    |> Map.put(:submissions, submissions)
    |> Map.put(:included, included)
  end
end
