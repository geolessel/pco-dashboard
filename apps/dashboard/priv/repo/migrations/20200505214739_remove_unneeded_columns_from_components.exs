defmodule Dashboard.Repo.Migrations.RemoveUnneededColumnsFromComponents do
  use Ecto.Migration

  def change do
    alter table(:components) do
      remove :api_path
      remove :assign
    end
  end
end
