defmodule Dashboard.Components.Configuration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "configurations" do
    field :label, :string
    field :name, :string
    belongs_to :component, Dashboard.Dashboards.Component

    timestamps()
  end

  @doc false
  def changeset(configuration, attrs) do
    configuration
    |> cast(attrs, [:label, :name, :component_id])
    |> validate_required([:label, :name, :component_id])
    |> validate_length(:name, min: 2)
    |> validate_length(:label, min: 2)
    |> assoc_constraint(:component)
  end
end
