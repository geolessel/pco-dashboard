defmodule Dashboard.Dashboards.Component do
  use Ecto.Schema
  import Ecto.Changeset

  schema "components" do
    field :api_path, :string
    field :assign, :string
    field :module, :string
    field :name, :string, default: "poll"
    field :refresh_type, :string, default: "poll"

    timestamps()
  end

  @doc false
  def changeset(component, attrs) do
    component
    |> cast(attrs, [:name, :api_path, :module, :assign, :refresh_type])
    |> validate_required([:name, :api_path, :module, :assign, :refresh_type])
  end

  def to_module(%__MODULE__{module: module}) do
    String.to_atom("Elixir." <> module)
  end
end
