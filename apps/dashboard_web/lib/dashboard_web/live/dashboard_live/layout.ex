defmodule DashboardWeb.DashboardLive.Layout do
  use DashboardWeb, :live_view

  alias Dashboard.{Accounts, Dashboards}

  @impl true
  # TODO: can all this be done with a user_id instead of a user_token?
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
  def handle_event("save", %{"component" => %{"component_id" => component_id}}, socket) do
    user = Accounts.get_user_by_session_token(socket.assigns.user_token)
    dashboard = socket.assigns.dashboard

    # TODO: handle the error!
    # TODO: is the double-reverse of the list faster or slower than appending the list directly?
    case Dashboards.create_dashboard_component(%{
           dashboard_id: dashboard.id,
           component_id: component_id,
           user_id: user.id
         }) do
      {:ok, dc} ->
        {:noreply,
         assign(
           socket,
           :dashboard_components,
           Enum.reverse([dc | Enum.reverse(socket.assigns.dashboard_components)])
         )}
    end
  end

  @impl true
  def handle_event("add-component", %{"component-id" => component_id}, socket) do
    user = Accounts.get_user_by_session_token(socket.assigns.user_token)
    dashboard = socket.assigns.dashboard

    # TODO: handle the error!
    # TODO: is the double-reverse of the list faster or slower than appending the list directly?
    case Dashboards.create_dashboard_component(%{
           dashboard_id: dashboard.id,
           component_id: component_id,
           user_id: user.id
         }) do
      {:ok, dc} ->
        {:noreply,
         assign(
           socket,
           :dashboard_components,
           Enum.reverse([dc | Enum.reverse(socket.assigns.dashboard_components)])
         )}
    end
  end

  @impl true
  def handle_event(
        "remove-component",
        %{"dc-id" => dc_id} = _params,
        %{assigns: %{dashboard: dashboard}} = socket
      ) do
    # TODO: handle the error!
    dashboard
    |> Dashboards.get_dashboard_component_of_dashboard!(dc_id)
    |> Dashboards.delete_dashboard_component()
    |> case do
      {:ok, _} ->
        user = Accounts.get_user_by_session_token(socket.assigns.user_token)
        dashboard = Dashboards.get_dashboard!(dashboard.id, user.id)

        {:noreply,
         assign(
           socket,
           :dashboard_components,
           dashboard.dashboard_components
         )}
    end
  end

  @impl true
  def handle_event(
        "reorder-component",
        %{"dc_id" => dc_id, "new_sequence" => new_sequence},
        socket
      ) do
    dashboard = socket.assigns.dashboard

    # TODO: handle error
    dashboard
    |> Dashboards.get_dashboard_component_of_dashboard!(dc_id)
    |> Dashboards.reorder_component(new_sequence)
    |> case do
      {:ok, _} ->
        user = Accounts.get_user_by_session_token(socket.assigns.user_token)
        dashboard = Dashboards.get_dashboard!(dashboard.id, user.id)
        {:noreply, assign(socket, :dashboard_components, dashboard.dashboard_components)}
    end
  end

  defp page_title(:edit), do: "Edit Dashboard Layout"
end
