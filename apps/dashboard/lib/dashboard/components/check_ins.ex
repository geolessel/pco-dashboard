defmodule Dashboard.Components.CheckIns do
  use Dashboard.Component
  alias Dashboard.PlanningCenterApi.Response

  @impl true
  def data_sources do
    %{
      checkins:
        "/check-ins/v2/check_ins?order=-updated_at&per_page=8&fields[CheckIn]=first_name,last_name,kind,medical_notes"
    }
  end

  @impl true
  def process_data(%{checkins: %Response{} = response} = state) do
    checkins = Response.dig(response, [:body, "data"])

    Map.put(state, :checkins, checkins)
  end
end
