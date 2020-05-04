defmodule Dashboard.Repo.Migrations.CreateDashboardComponentConfigurations do
  use Ecto.Migration

  def change do
    create table(:dashboard_component_configurations) do
      add :dashboard_component_id, references(:dashboard_components, on_delete: :delete_all),
        null: false

      add :configuration_id, references(:configurations, on_delete: :delete_all), null: false
      add :value, :string, null: false

      timestamps()
    end

    create index(:dashboard_component_configurations, [:dashboard_component_id])

    create unique_index(:dashboard_component_configurations, [
             :configuration_id,
             :dashboard_component_id
           ])
  end
end
