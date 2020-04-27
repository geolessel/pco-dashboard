defmodule Dashboard.Repo.Migrations.AddAccessTokenInformationToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :application_id, :string
      add :application_secret, :string
    end
  end
end
