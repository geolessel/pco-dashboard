defmodule DashboardWeb.DashboardLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Accounts, Dashboards}
  alias Dashboard.Dashboards.Component

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    {:ok,
     socket
     |> assign(:components, [])
     |> assign(:user_id, user.id)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :help, params) do
    apply_action(socket, :show, params)
    |> assign(:shortcuts, [{"shift-l", "Edit dashboard layout"}])
  end

  defp apply_action(socket, :show, %{"slug" => slug}) do
    user = Accounts.get_user!(socket.assigns.user_id)
    dashboard = Dashboards.get_dashboard_by_slug!(slug, socket.assigns.user_id)

    component_subscriptions =
      dashboard.dashboard_components
      |> Enum.map(fn dc ->
        module = Dashboard.Dashboards.Component.to_module(dc.component)

        name =
          module.genserver_id(
            socket.assigns,
            dc
          )

        {:ok, pid} =
          Dashboard.Stores.subscribe(
            module.data_module(),
            name,
            self(),
            dc,
            user
          )

        {module.data_module(), name, pid}
      end)

    socket
    |> assign(:component_subscriptions, component_subscriptions)
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:components, dashboard.dashboard_components)
    |> assign(:dashboard, dashboard)
  end

  @impl true
  def handle_info(:tell_components_to_update, socket) do
    Enum.each(socket.assigns.components, fn dc ->
      send_update(Component.to_module(dc.component),
        id: dc.id,
        component: dc.component,
        dashboard_component: dc,
        user_id: socket.assigns.user_id
      )
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("keyboard-shortcut", %{"key" => "L"}, socket) do
    {:noreply,
     push_redirect(socket,
       to: Routes.dashboard_layout_path(socket, :edit, socket.assigns.dashboard)
     )}
  end

  @impl true
  def handle_event("keyboard-shortcut", %{"key" => "?"}, socket) do
    {:noreply,
     push_redirect(socket,
       to: Routes.dashboard_show_path(socket, :help, socket.assigns.dashboard)
     )}
  end

  @impl true
  def handle_event("keyboard-shortcut", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    socket.assigns.component_subscriptions
    |> Enum.each(fn {data_module, name, _pid} ->
      Dashboard.Stores.unsubscribe(data_module, name, self())
    end)
  end

  defp page_title(:show), do: "Show Dashboard"
  defp page_title(:edit), do: "Edit Dashboard"
  defp page_title(:help), do: "Keyboard Shortcuts"
end
