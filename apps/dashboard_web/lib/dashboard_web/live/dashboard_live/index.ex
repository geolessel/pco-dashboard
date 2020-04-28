defmodule DashboardWeb.DashboardLive.Index do
  use DashboardWeb, :live_view

  alias Dashboard.Accounts
  alias Dashboard.Dashboards
  alias Dashboard.Dashboards.Dashboard

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    socket = assign_user_id(socket, user_token)
    {:ok, assign(socket, :dashboards, fetch_dashboards(socket.assigns.user_id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"slug" => slug}) do
    socket
    |> assign(:page_title, "Edit Dashboard")
    |> assign(:dashboard, Dashboards.get_dashboard_by_slug!(slug, socket.assigns.user_id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Dashboard")
    |> assign(:dashboard, %Dashboard{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Dashboards")
    |> assign(:dashboard, nil)
  end

  @impl true
  def handle_event("delete", %{"slug" => slug}, %{assigns: %{user_id: user_id}} = socket) do
    dashboard = Dashboards.get_dashboard_by_slug!(slug, user_id)
    {:ok, _} = Dashboards.delete_dashboard(dashboard)

    {:noreply, assign(socket, :dashboards, fetch_dashboards(user_id))}
  end

  defp assign_user_id(socket, user_token) do
    assign_new(socket, :user_id, fn ->
      fetch_user_id_from_token(user_token)
    end)
  end

  defp fetch_user_id_from_token(user_token) do
    Accounts.get_user_by_session_token(user_token).id
  end

  defp fetch_dashboards(user_id) do
    Dashboards.list_dashboards(user_id)
  end
end
