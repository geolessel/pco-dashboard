defmodule Dashboard.Dashboards.DashboardComponent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Dashboard.Dashboards.{Component, Dashboard}

  schema "dashboard_components" do
    belongs_to :dashboard, Dashboard
    belongs_to :component, Component

    timestamps()
  end

  @doc false
  def changeset(dashboard_component, attrs) do
    dashboard_component
    |> cast(attrs, [:dashboard_id, :component_id])
    |> validate_required([:dashboard_id, :component_id])
    |> assoc_constraint(:dashboard)
    |> assoc_constraint(:component)
  end
end
