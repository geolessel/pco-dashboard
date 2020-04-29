defmodule Dashboard.Repo.Migrations.AddSequenceToDashboardComponents do
  use Ecto.Migration

  def change do
    alter table(:dashboard_components) do
      add :sequence, :integer, null: false
    end

    create unique_index(:dashboard_components, [:sequence, :dashboard_id])
  end
end
