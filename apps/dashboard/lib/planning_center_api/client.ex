defmodule Dashboard.PlanningCenterApi.Client do
  @api_transport Application.compile_env(:dashboard, :api_transport)
  @api_base Application.compile_env(:dashboard, :api_base)
  @api_port Application.compile_env(:dashboard, :api_port)

  def get(%Dashboard.Accounts.User{application_id: _, application_secret: _} = user, path) do
    get_connection()
    |> Dashboard.ApiClient.get(user, path)
    |> Dashboard.PlanningCenterApi.Response.from_mint()
  end

  defp get_connection do
    {:ok, pid} = GenServer.start_link(Dashboard.ApiClient, {@api_transport, @api_base, @api_port})

    pid
  end
end
