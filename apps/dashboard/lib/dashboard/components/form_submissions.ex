defmodule Dashboard.Components.FormSubmissions do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @impl true
  def data_sources do
    %{
      submissions:
        "/people/v2/forms/${form_id}/form_submissions?include=person&per_page=8&order=-created_at",
      form: "/people/v2/forms/${form_id}"
    }
  end

  @impl true
  def process_data(
        %{submissions: %Response{} = submissions_response, form: %Response{} = form_response} =
          state
      ) do
    submissions =
      submissions_response
      |> Response.dig([:body, "data"])

    included =
      submissions_response
      |> Response.dig([:body, "included"])

    form_name =
      form_response
      |> Response.dig([:body, "data", "attributes", "name"])

    state
    |> Map.put(:submissions, submissions)
    |> Map.put(:included, included)
    |> Map.put(:form_name, form_name)
  end
end
