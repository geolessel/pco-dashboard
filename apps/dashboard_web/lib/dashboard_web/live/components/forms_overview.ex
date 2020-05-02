defmodule DashboardWeb.Components.FormsOverview do
  use DashboardWeb, :live_component

  alias Dashboard.Accounts

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :forms, [])}
  end

  @impl true
  def update(assigns, socket) do
    forms = Dashboard.Stores.ComponentStore.get({:global, get_id(assigns)}, "forms")

    {:ok, assign(socket, :forms, forms)}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card">
      <div class="card-header">
        <h1 class="card-title">
          Form Overview
        </h1>
        <div class="card-icon">P</div>
      </div>
      <div class="p-4">
        <table class="clean-table">
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
      </div>
    </div>
    """
  end

  def get_id(assigns) do
    "forms_overview--user_#{assigns.user_id}"
  end
end
