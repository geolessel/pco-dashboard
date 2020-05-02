defmodule DashboardWeb.Components.PersonUpdated do
  use DashboardWeb, :live_component

  alias Dashboard.Accounts

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :people, [])}
  end

  @impl true
  def update(assigns, socket) do
    people = Dashboard.Stores.ComponentStore.get({:global, get_id(assigns)}, "people")

    {:ok, assign(socket, :people, people)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card">
      <div class="card-header">
        <h1 class="card-title">
          Last Updated
        </h1>
        <div class="card-icon">P</div>
      </div>
      <div class="p-4">
        <table class="clean-table">
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
      </div>
    </div>
    """
  end

  def get_id(assigns) do
    "person_updated--user_#{assigns.user_id}"
  end
end
