defmodule Dashboard.Components.PersonUpdated do
  use Dashboard.Component

  @impl true
  def data_sources do
    %{people: "/people/v2/people?order=-updated_at&per_page=8&fields[Person]=name,updated_at"}
  end
end
