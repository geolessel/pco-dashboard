defmodule Dashboard.Oauth do
  defstruct [:token, :expires_at, :refresh_token, :type]
end
