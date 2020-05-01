defmodule DashboardWeb.DashboardLive.Show do
  use DashboardWeb, :live_view

  alias Dashboard.{Accounts, Dashboards}
  alias Dashboard.Dashboards.Component

  @poll_interval 10_000

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    :timer.send_interval(@poll_interval, :tell_components_to_update)

    {:ok,
     socket
     |> assign(:components, [])
     |> assign(:user_id, user.id)}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    dashboard = Dashboards.get_dashboard_by_slug!(slug, socket.assigns.user_id)

    component_subscriptions =
      dashboard.dashboard_components
      |> Enum.map(fn dc ->
        name = Dashboard.Dashboards.Component.to_module(dc.component).get_id(socket.assigns)

        {:ok, pid} =
          Dashboard.Stores.subscribe(
            name,
            self(),
            dc.component,
            user
          )

        {name, pid}
      end)

    {:noreply,
     socket
     |> assign(:component_subscriptions, component_subscriptions)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:components, dashboard.dashboard_components)
     |> assign(:dashboard, dashboard)}
  end

  @impl true
  def handle_info(:tell_components_to_update, socket) do
    Enum.each(socket.assigns.components, fn dc ->
      send_update(Component.to_module(dc.component),
        id: dc.id,
        component: dc.component,
        user_id: socket.assigns.user_id
      )
    end)

    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    socket.assigns.component_subscriptions
    |> Enum.each(fn {name, _pid} -> Dashboard.Stores.unsubscribe(name, self()) end)
  end

  defp page_title(:show), do: "Show Dashboard"
  defp page_title(:edit), do: "Edit Dashboard"
end
