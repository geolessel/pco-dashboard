defmodule Dashboard.Repo.Migrations.CreateConfigurations do
  use Ecto.Migration

  def change do
    create table(:configurations) do
      add :label, :string, null: false
      add :name, :string, null: false
      add :component_id, references(:components, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:configurations, [:component_id])
  end
end
