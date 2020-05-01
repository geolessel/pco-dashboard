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
    <div class="bg-white col-span-2 rounded-lg overflow-hidden shadow-base shadow-lg">
      <div class="bg-alabaster flex mt-2 px-4 items-center border-l-2 border-app-people">
        <h1 class="flex-1 mr-2 py-1 text-gray-800 text-base font-bold">Last Updated</h1>
        <div class="bg-app-people text-white w-5 h-5 text-center text-sm rounded">P</div>
      </div>
      <div class="p-4">
        <table class="table-auto leading-6 w-full">
          <thead class="text-gray-500 uppercase text-xs text-left">
            <tr>
              <th class="px-2 py-0">Name</th>
              <th class="px-2 py-0">Updated</th>
            </tr>
          </thead>
          <tbody class="align-baseline text-gray-700 text-sm">
            <%= for person <- @people do %>
              <tr class="odd:bg-gray-100">
                <td class="px-2 py-0"><%= person["attributes"]["name"] %></td>
                <td class="px-2 py-0"><%= person["attributes"]["updated_at"] %></td>
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
