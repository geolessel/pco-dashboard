defmodule DashboardWeb.OauthController do
  use DashboardWeb, :controller

  def new(conn, %{"code" => code}) do
    response = Dashboard.PlanningCenterApi.Oauth.get_token!(code: code)

    attrs = %{
      user_id: conn.assigns.current_user.id,
      access_token: response.token.access_token,
      refresh_token: response.token.refresh_token,
      expires_at: DateTime.from_unix!(response.token.expires_at)
    }

    case conn.assigns.current_user.oauth_token do
      nil -> Dashboard.Accounts.create_oauth_token(attrs)
      token -> Dashboard.Accounts.update_oauth_token(token, attrs)
    end

    redirect(conn, to: Routes.user_settings_path(conn, :edit))
  end
end
