defmodule Dashboard.Dashboards.Dashboard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dashboards" do
    field :name, :string
    field :slug, :string
    belongs_to :user, Dashboard.Accounts.User
    has_many :dashboard_components, Dashboard.Dashboards.DashboardComponent
    has_many :components, through: [:dashboard_components, :component]

    timestamps()
  end

  @doc false
  def changeset(dashboard, attrs) do
    dashboard
    |> cast(attrs, [:name, :slug, :user_id])
    |> validate_required([:name, :slug, :user_id])
    |> validate_length(:name, min: 3)
    |> validate_length(:slug, min: 3)
    |> validate_format(:slug, ~r/^[a-zA-Z0-9-_]+$/,
      message: "must contain only letters, numbers, dashes (-), or underscores (_)"
    )
    |> validate_exclusion(:slug, ~w(new edit update destroy delete show layout admin))
    |> assoc_constraint(:user)
    |> unique_constraint([:slug, :user_id])
  end
end
