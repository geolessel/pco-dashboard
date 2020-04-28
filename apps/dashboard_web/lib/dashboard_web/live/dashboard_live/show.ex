defmodule DashboardWeb.DashboardLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Accounts, Dashboards}

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    send(self(), :fetch_people)
    :timer.send_interval(30_000, :fetch_people)

    {:ok,
     socket
     |> assign(:user_token, user_token)}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    user = Accounts.get_user_by_session_token(socket.assigns.user_token)
    dashboard = Dashboards.get_dashboard_by_slug!(slug, user.id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:people, [])
     |> assign(:dashboard, dashboard)}
  end

  @impl true
  def handle_info(:fetch_people, socket) do
    user = Accounts.get_user_by_session_token(socket.assigns.user_token)

    people =
      Map.get(
        Dashboard.PlanningCenterApi.Client.get(
          user,
          "/people/v2/people?order=-updated_at&per_page=5&fields[Person]=name,updated_at"
        ),
        :body,
        %{}
      )
      |> Map.get("data", [])

    {:noreply,
     assign(
       socket,
       :people,
       people
     )}
  end

  defp page_title(:show), do: "Show Dashboard"
  defp page_title(:edit), do: "Edit Dashboard"
end
