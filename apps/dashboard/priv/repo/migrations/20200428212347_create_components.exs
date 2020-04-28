defmodule Dashboard.Repo.Migrations.CreateComponents do
  use Ecto.Migration

  def change do
    create table(:components) do
      add :name, :string, null: false
      add :api_path, :string, null: false
      add :module, :string, null: false
      add :assign, :string, null: false
      add :refresh_type, :string, null: false

      timestamps()
    end
  end
end
