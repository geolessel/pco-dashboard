defmodule Dashboard.Repo.Migrations.CreateOauthTokens do
  use Ecto.Migration

  def change do
    create table(:oauth_tokens) do
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :naive_datetime
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:oauth_tokens, [:user_id])
  end
end
