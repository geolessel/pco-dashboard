defmodule Dashboard.PlanningCenterApi.Oauth do
  use OAuth2.Strategy

  @client_id Application.compile_env(:dashboard, :oauth_client_id)
  @client_secret Application.compile_env(:dashboard, :oauth_client_secret)
  @redirect_url Application.compile_env(:dashboard, :oauth_callback_url)

  def client(opts \\ []) do
    OAuth2.Client.new(
      strategy: __MODULE__,
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: @redirect_url,
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

  def refresh!(refresh_token) do
    OAuth2.Client.new(
      strategy: OAuth2.Strategy.Refresh,
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: @redirect_url,
      site: "https://api.planningcenteronline.com",
      authorize_url: "https://api.planningcenteronline.com/oauth/authorize",
      token_url: "https://api.planningcenteronline.com/oauth/token",
      params: %{"refresh_token" => refresh_token}
    )
    |> OAuth2.Client.put_serializer("application/json", Jason)
    |> OAuth2.Client.get_token!()
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

  def to_db_attrs(response) do
    %{
      access_token: response.token.access_token,
      refresh_token: response.token.refresh_token,
      expires_at: DateTime.from_unix!(response.token.expires_at)
    }
  end
end
