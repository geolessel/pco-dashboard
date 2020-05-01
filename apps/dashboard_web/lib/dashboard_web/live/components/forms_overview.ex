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
    <div class="bg-white col-span-2 rounded-lg overflow-hidden shadow-base shadow-lg">
      <div class="bg-alabaster flex mt-2 px-4 items-center border-l-2 border-app-people">
        <h1 class="flex-1 mr-2 py-1 text-gray-800 text-base font-bold">Form Overview</h1>
        <div class="bg-app-people text-white w-5 h-5 text-center text-sm rounded">P</div>
      </div>
      <div class="p-4">
        <table class="table-auto leading-6 w-full">
          <thead class="text-gray-500 uppercase text-xs text-left">
            <tr>
              <th class="px-2 py-0">Form</th>
              <th class="px-2 py-0">Submissions</th>
              <th class="px-2 py-0">Latest</th>
            </tr>
          </thead>
          <tbody class="align-baseline text-gray-700 text-sm">
            <%= for form <- @forms do %>
              <tr class="odd:bg-gray-100">
                <td class="px-2 py-0"><%= form["attributes"]["name"] %></td>
                <td class="px-2 py-0"><%= form["attributes"]["submission_count"] %></td>
                <td class="px-2 py-0">???</td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
