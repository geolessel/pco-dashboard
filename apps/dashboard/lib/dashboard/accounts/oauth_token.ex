defmodule Dashboard.Accounts.OauthToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "oauth_tokens" do
    field :access_token, :string
    field :expires_at, :naive_datetime
    field :refresh_token, :string
    belongs_to :user, Dashboard.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(oauth_token, attrs) do
    oauth_token
    |> cast(attrs, [:access_token, :refresh_token, :expires_at, :user_id])
    |> validate_required([:access_token, :refresh_token, :expires_at, :user_id])
  end
end
