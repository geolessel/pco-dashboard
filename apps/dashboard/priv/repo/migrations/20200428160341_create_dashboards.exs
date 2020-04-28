defmodule Dashboard.Repo.Migrations.CreateDashboards do
  use Ecto.Migration

  def change do
    create table(:dashboards) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:dashboards, [:user_id])
    create unique_index(:dashboards, [:slug, :user_id])
  end
end
