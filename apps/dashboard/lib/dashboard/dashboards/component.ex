defmodule Dashboard.Dashboards.Component do
  use Ecto.Schema
  import Ecto.Changeset

  schema "components" do
    field :module, :string
    field :name, :string
    field :refresh_type, :string, default: "poll"
    has_many :configurations, Dashboard.Components.Configuration

    timestamps()
  end

  @doc false
  def changeset(component, attrs) do
    component
    |> cast(attrs, [:name, :module, :refresh_type])
    |> validate_required([:name, :module, :refresh_type])
  end

  def to_module(%__MODULE__{module: module}) do
    String.to_existing_atom("Elixir." <> module)
  end
end
