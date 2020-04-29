defmodule DashboardWeb.DashboardLive.Layout do
  use DashboardWeb, :live_view

  alias Dashboard.{Accounts, Dashboards}
  alias Dashboard.Dashboards.Component

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    {:ok,
     socket
     |> assign(:components, [])
     |> assign(:user_token, user_token)}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    user = Accounts.get_user_by_session_token(socket.assigns.user_token)
    dashboard = Dashboards.get_dashboard_by_slug!(slug, user.id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:dashboard_components, dashboard.dashboard_components)
     |> assign(:all_components, Dashboards.list_components())
     |> assign(:dashboard, dashboard)}
  end

  @impl true
  def handle_event("add-component", %{"component-id" => component_id} = params, socket) do
    dashboard = socket.assigns.dashboard

    # TODO: handle the error!
    case Dashboards.create_dashboard_component(%{
           dashboard_id: dashboard.id,
           component_id: component_id
         }) do
      {:ok, dc} ->
        {:noreply,
         assign(
           socket,
           :dashboard_components,
           Enum.reverse([dc | socket.assigns.dashboard_components])
         )}
    end
  end

  @impl true
  def handle_event(
        "remove-component",
        %{"dc-id" => dc_id} = params,
        %{assigns: %{dashboard: dashboard, dashboard_components: dashboard_components}} = socket
      ) do
    dashboard = socket.assigns.dashboard

    # TODO: handle the error!
    dashboard
    |> Dashboards.get_dashboard_component_of_dashboard!(dc_id)
    |> Dashboards.delete_dashboard_component()
    |> case do
      {:ok, _} ->
        {:noreply,
         assign(
           socket,
           :dashboard_components,
           Enum.filter(dashboard_components, fn %{id: id} -> id != String.to_integer(dc_id) end)
         )}
    end
  end

  defp page_title(:show), do: "Show Dashboard Layout"
  defp page_title(:edit), do: "Edit Dashboard Layout"
end
