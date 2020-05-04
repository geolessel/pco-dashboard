defmodule Dashboard.Dashboards.ComponentConfiguration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dashboard_component_configurations" do
    belongs_to :dashboard_component, Dashboard.Dashboards.DashboardComponent
    belongs_to :configuration, Dashboard.Components.Configuration
    field :value, :string

    timestamps()
  end

  @doc false
  def changeset(component_configuration, attrs) do
    component_configuration
    |> cast(attrs, [:dashboard_configuration_id, :configuration_id, :value])
    |> validate_required([:dashboard_configuration_id, :configuration_id, :value])
    |> assoc_constraint(:dashboard_component)
    |> assoc_constraint(:configuration)
  end
end
