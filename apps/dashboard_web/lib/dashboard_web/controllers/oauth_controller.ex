defmodule DashboardWeb.OauthController do
  use DashboardWeb, :controller

  def new(conn, %{"code" => code}) do
    attrs =
      Dashboard.PlanningCenterApi.Oauth.get_token!(code: code)
      |> Dashboard.PlanningCenterApi.Oauth.to_db_attrs()
      |> Map.put(:user_id, conn.assigns.current_user.id)

    case conn.assigns.current_user.oauth_token do
      nil -> Dashboard.Accounts.create_oauth_token(attrs)
      token -> Dashboard.Accounts.update_oauth_token(token, attrs)
    end

    redirect(conn, to: Routes.user_settings_path(conn, :edit))
  end
end
