defmodule DashboardWeb.ComponentHelpers do
  @moduledoc """
  Helpers for rendering components in a Dashboard.
  """

  def get_trend_color(n, n), do: "gray"
  def get_trend_color(cur, prev) when cur > prev, do: "green"
  def get_trend_color(cur, prev) when cur < prev, do: "red"

  def get_trend_icon(n, n), do: "\u2B62"
  def get_trend_icon(cur, prev) when cur > prev, do: "\u2B5C"
  def get_trend_icon(cur, prev) when cur < prev, do: "\u2B5D"

  def get_trend_percent(cur, prev), do: get_percent(cur, prev) |> Float.round(1) |> add_plus_str()

  defp add_plus_str(num) when num > 0, do: "+#{num}"
  defp add_plus_str(num), do: "#{num}"

  defp get_percent(0, 0), do: 0.0
  defp get_percent(_, 0), do: -100.0
  defp get_percent(0, _), do: 100.0
  defp get_percent(cur, prev), do: (cur / prev - 1) * 100.0
end
