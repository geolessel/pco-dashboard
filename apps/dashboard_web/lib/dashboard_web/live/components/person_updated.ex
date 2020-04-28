defmodule DashboardWeb.Components.PersonUpdated do
  use DashboardWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
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
