defmodule Dashboard.Dashboards do
  @moduledoc """
  The Dashboards context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Dashboards.{Dashboard, DashboardComponent, Component}

  @doc """
  Returns the list of dashboards for a user.

  ## Examples

      iex> list_dashboards(user_id)
      [%Dashboard{}, ...]

  """
  def list_dashboards(user_id) do
    from(d in Dashboard,
      where: d.user_id == ^user_id,
      order_by: d.name
    )
    |> Repo.all()
  end

  @doc """
  Gets a single dashboard belonging to a user.

  Raises `Ecto.NoResultsError` if the Dashboard does not exist.

  ## Examples

      iex> get_dashboard!(123, 1)
      %Dashboard{}

      iex> get_dashboard!(456, 1)
      ** (Ecto.NoResultsError)

  """
  def get_dashboard!(id, user_id) do
    Dashboard
    |> Repo.get_by!(%{id: id, user_id: user_id})
    |> preload_components()
  end

  @doc """
  Gets a single dashboard from a slug and user_id.

  Raises `Ecto.NoResultsError` if the Dashboard does not exist.

  ### Examples

       iex> get_dashboard_by_slug!("default", 1)
       %Dashboard{}

       iex> get_dashboard_by_slug!("invalid", 1)
       ** (Ecto.NoResultsError)

  """
  def get_dashboard_by_slug!(slug, user_id) do
    Dashboard
    |> Repo.get_by!(%{slug: slug, user_id: user_id})
    |> preload_components()
  end

  defp preload_components(query) do
    Repo.preload(query, :components,
      dashboard_components: from(dc in DashboardComponent, order_by: dc.sequence)
    )
  end

  @doc """
  Creates a dashboard.

  ## Examples

      iex> create_dashboard(%{field: value})
      {:ok, %Dashboard{}}

      iex> create_dashboard(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dashboard(attrs \\ %{}) do
    %Dashboard{}
    |> Dashboard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dashboard.

  ## Examples

      iex> update_dashboard(dashboard, %{field: new_value})
      {:ok, %Dashboard{}}

      iex> update_dashboard(dashboard, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dashboard(%Dashboard{} = dashboard, attrs) do
    dashboard
    |> Dashboard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dashboard.

  ## Examples

      iex> delete_dashboard(dashboard)
      {:ok, %Dashboard{}}

      iex> delete_dashboard(dashboard)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dashboard(%Dashboard{} = dashboard) do
    Repo.delete(dashboard)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dashboard changes.

  ## Examples

      iex> change_dashboard(dashboard)
      %Ecto.Changeset{data: %Dashboard{}}

  """
  def change_dashboard(%Dashboard{} = dashboard, attrs \\ %{}) do
    Dashboard.changeset(dashboard, attrs)
  end

  @doc """
  Returns the list of components.

  ## Examples

      iex> list_components()
      [%Component{}, ...]

  """
  def list_components do
    Repo.all(Component)
  end

  @doc """
  Gets a single component.

  Raises `Ecto.NoResultsError` if the Component does not exist.

  ## Examples

      iex> get_component!(123)
      %Component{}

      iex> get_component!(456)
      ** (Ecto.NoResultsError)

  """
  def get_component!(id), do: Repo.get!(Component, id)

  @doc """
  Creates a component.

  ## Examples

      iex> create_component(%{field: value})
      {:ok, %Component{}}

      iex> create_component(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_component(attrs \\ %{}) do
    %Component{}
    |> Component.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a component.

  ## Examples

      iex> update_component(component, %{field: new_value})
      {:ok, %Component{}}

      iex> update_component(component, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_component(%Component{} = component, attrs) do
    component
    |> Component.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a component.

  ## Examples

      iex> delete_component(component)
      {:ok, %Component{}}

      iex> delete_component(component)
      {:error, %Ecto.Changeset{}}

  """
  def delete_component(%Component{} = component) do
    Repo.delete(component)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking component changes.

  ## Examples

      iex> change_component(component)
      %Ecto.Changeset{data: %Component{}}

  """
  def change_component(%Component{} = component, attrs \\ %{}) do
    Component.changeset(component, attrs)
  end

  def get_dashboard_component_of_dashboard!(%Dashboard{id: dashboard_id}, id) do
    Repo.get_by!(DashboardComponent, %{id: id, dashboard_id: dashboard_id})
  end

  def change_dashboard_component(%DashboardComponent{} = dc, attrs \\ %{}) do
    DashboardComponent.changeset(dc, attrs)
  end

  def create_dashboard_component(attrs \\ %{}) do
    %DashboardComponent{}
    |> DashboardComponent.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, dc} -> {:ok, Repo.preload(dc, :component)}
      other -> other
    end
  end

  def delete_dashboard_component(%DashboardComponent{} = dc) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:delete, dc)
    |> Ecto.Multi.update_all(
      :resequence,
      from(d in DashboardComponent,
        where: d.dashboard_id == ^dc.dashboard_id,
        where: d.sequence > ^dc.sequence
      ),
      inc: [sequence: -1]
    )
    |> Repo.transaction()
  end

  def get_max_sequence_for_dashboard(%Dashboard{id: did} = dashboard) do
    Repo.one(
      from dc in DashboardComponent, where: dc.dashboard_id == ^did, select: max(dc.sequence)
    )
  end
end
