defmodule DashboardWeb.Components.PersonUpdated do
  use DashboardWeb, :live_component

  alias Dashboard.Accounts

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :people, [])}
  end

  @impl true
  def update(%{component: component} = assigns, socket) do
    user = Accounts.get_user_by_session_token(assigns.user_token)

    people =
      user
      |> Dashboard.PlanningCenterApi.Client.get(component.api_path)
      |> Map.get(:body, %{})
      |> Map.get("data", [])

    {:ok, assign(socket, :people, people)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Updated</th>
        </tr>
      </thead>
      <tbody>
        <%= for person <- @people do %>
          <tr>
            <td><%= person["attributes"]["name"] %></td>
            <td><%= person["attributes"]["updated_at"] %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
