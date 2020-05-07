defmodule DashboardWeb.ComponentHelpers do
  @moduledoc """
  Helpers for rendering components in a Dashboard.
  """
  alias DashboardWeb.Router.Helpers, as: Routes

  def get_trend_color(n, n), do: "gray"
  def get_trend_color(cur, prev) when cur > prev, do: "green"
  def get_trend_color(cur, prev) when cur < prev, do: "red"

  def get_trend_icon(n, n), do: "\u2B62"
  def get_trend_icon(cur, prev) when cur > prev, do: "\u2B5C"
  def get_trend_icon(cur, prev) when cur < prev, do: "\u2B5D"

  def get_trend_percent(cur, prev), do: get_percent(cur, prev) |> Float.round(1) |> add_plus_str()

  def get_human_number(n) when is_number(n) do
    case n do
      n when n >= 100_000_000 -> "#{round(n / 1_000_000)}M"
      n when n >= 10_000_000 -> "#{Float.round(n / 1_000_000, 1)}M"
      n when n >= 1_000_000 -> "#{Float.round(n / 1_000_000, 2)}M"
      n when n >= 100_000 -> "#{Float.round(n / 1_000, 1)}K"
      n when n >= 10_000 -> "#{Float.round(n / 1_000, 2)}K"
      n when n >= 1_000 -> Number.Delimit.number_to_delimited(n, precision: 0)
      n -> "#{n}"
    end
  end

  def get_human_number(_), do: "0"

  defp add_plus_str(num) when num > 0, do: "+#{num}"
  defp add_plus_str(num), do: "#{num}"

  defp get_percent(nil, _), do: 0.0
  defp get_percent(_, nil), do: 0.0
  defp get_percent(0, 0), do: 0.0
  defp get_percent(_, 0), do: -100.0
  defp get_percent(0, _), do: 100.0
  defp get_percent(cur, prev), do: (cur / prev - 1) * 100.0

  def svg_icon(conn, icon) do
    {:safe,
     """
     <svg class="symbol" role="image">
       <use href="#{Routes.static_path(conn, "/js/sprite.svg##{icon}")}">
       </use>
     </svg>
     """}
  end
end
