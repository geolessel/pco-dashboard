defmodule Dashboard.PlanningCenterApi.Oauth do
  use OAuth2.Strategy

  def client do
    OAuth2.Client.new(
      strategy: __MODULE__,
      client_id: Application.get_env(:dashboard, :oauth_client_id),
      client_secret: Application.get_env(:dashboard, :oauth_client_secret),
      redirect_uri: Application.get_env(:dashboard, :oauth_callback_url),
      site: "https://api.planningcenteronline.com",
      authorize_url: "https://api.planningcenteronline.com/oauth/authorize",
      token_url: "https://api.planningcenteronline.com/oauth/token"
    )
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client(),
      scope: "check_ins giving groups people calendar services"
    )
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
