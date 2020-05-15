defmodule DashboardWeb.HealthController do
  use DashboardWeb, :controller

  def index(conn, _params) do
    json(
      conn,
      %{
        hostname: hostname(),
        node: node(),
        versions: versions()
      }
    )
  end

  defp hostname do
    with {name, 0} <- System.cmd("hostname", []),
         name <- String.trim(name) do
      name
    end
  end

  defp versions do
    [:dashboard, :dashboard_web]
    |> Enum.reduce(%{}, fn app, map ->
      version = Application.spec(app, :vsn) |> to_string()
      Map.put(map, app, version)
    end)
  end
end
