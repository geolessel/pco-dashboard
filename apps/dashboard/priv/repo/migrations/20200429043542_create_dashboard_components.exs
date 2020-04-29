defmodule Dashboard.Repo.Migrations.CreateDashboardComponents do
  use Ecto.Migration

  def change do
    create table(:dashboard_components) do
      add :dashboard_id, references(:dashboards, on_delete: :delete_all), null: false
      add :component_id, references(:components, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
