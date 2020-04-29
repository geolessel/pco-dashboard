defmodule Dashboard.Dashboards.DashboardComponent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Dashboards.{Component}

  schema "dashboard_components" do
    belongs_to :dashboard, Dashboard.Dashboards.Dashboard
    belongs_to :component, Component
    field :sequence, :integer

    timestamps()
  end

  @doc false
  def changeset(dashboard_component, attrs) do
    dashboard_component
    |> cast(ensure_sequence_set(attrs), [:dashboard_id, :component_id, :sequence])
    |> validate_required([:dashboard_id, :component_id, :sequence])
    |> assoc_constraint(:dashboard)
    |> assoc_constraint(:component)
    |> unique_constraint([:sequence, :dashboard_id])
  end

  defp ensure_sequence_set(%{"sequence" => sequence} = attrs) when is_integer(sequence), do: attrs
  defp ensure_sequence_set(%{sequence: sequence} = attrs) when is_integer(sequence), do: attrs

  defp ensure_sequence_set(%{user_id: user_id, dashboard_id: did} = attrs) do
    sequence =
      did
      |> Dashboard.Dashboards.get_dashboard!(user_id)
      |> Dashboard.Dashboards.get_max_sequence_for_dashboard()
      |> case do
        nil -> 0
        num -> num + 1
      end

    Map.put(attrs, :sequence, sequence)
  end
end
