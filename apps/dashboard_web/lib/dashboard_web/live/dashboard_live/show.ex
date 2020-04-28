defmodule DashboardWeb.DashboardLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Accounts, Dashboards}

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    {:ok, assign(socket, :user_id, fetch_user_id_from_token(user_token))}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:dashboard, Dashboards.get_dashboard_by_slug!(slug, socket.assigns.user_id))}
  end

  defp page_title(:show), do: "Show Dashboard"
  defp page_title(:edit), do: "Edit Dashboard"

  defp fetch_user_id_from_token(user_token) do
    Accounts.get_user_by_session_token(user_token).id
  end
end
