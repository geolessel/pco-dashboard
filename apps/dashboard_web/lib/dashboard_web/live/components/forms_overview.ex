defmodule DashboardWeb.Components.FormsOverview do
  use DashboardWeb, :live_component

  alias Dashboard.Accounts

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :forms, [])}
  end

  @impl true
  def update(%{component: component, user_token: user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    forms =
      user
      |> Dashboard.PlanningCenterApi.Client.get(component.api_path)
      |> Map.get(:body, %{})
      |> Map.get("data", [])

    {:ok, assign(socket, :forms, forms)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <table>
      <thead>
        <tr>
          <th>Form</th>
          <th>Submissions</th>
          <th>Latest</th>
        </tr>
      </thead>
      <tbody>
        <%= for form <- @forms do %>
          <tr>
            <td><%= form["attributes"]["name"] %></td>
            <td><%= form["attributes"]["submission_count"] %></td>
            <td>???</td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
