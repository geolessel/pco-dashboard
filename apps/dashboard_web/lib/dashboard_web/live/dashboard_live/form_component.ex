defmodule DashboardWeb.DashboardLive.FormComponent do
  use DashboardWeb, :live_component

  alias Dashboard.Dashboards

  @impl true
  def update(%{dashboard: dashboard} = assigns, socket) do
    changeset = Dashboards.change_dashboard(dashboard)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"dashboard" => dashboard_params}, socket) do
    changeset =
      socket.assigns.dashboard
      |> Dashboards.change_dashboard(dashboard_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"dashboard" => dashboard_params}, socket) do
    save_dashboard(
      socket,
      socket.assigns.action,
      Map.put(dashboard_params, "user_id", socket.assigns.user_id)
    )
  end

  defp save_dashboard(socket, :edit, dashboard_params) do
    case Dashboards.update_dashboard(socket.assigns.dashboard, dashboard_params) do
      {:ok, _dashboard} ->
        {:noreply,
         socket
         |> put_flash(:info, "Dashboard updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_dashboard(socket, :new, dashboard_params) do
    case Dashboards.create_dashboard(dashboard_params) do
      {:ok, _dashboard} ->
        {:noreply,
         socket
         |> put_flash(:info, "Dashboard created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
