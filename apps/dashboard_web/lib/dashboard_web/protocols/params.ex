defimpl Phoenix.Param, for: Dashboard.Dashboards.Dashboard do
  def to_param(%Dashboard.Dashboards.Dashboard{slug: slug}), do: slug
end
