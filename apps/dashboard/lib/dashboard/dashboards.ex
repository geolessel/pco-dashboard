defmodule Dashboard.Dashboards do
  @moduledoc """
  The Dashboards context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  # this naming is a nightmare
  alias Dashboard.Dashboards.{Dashboard, DashboardComponent, Component, ComponentConfiguration}

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
    Repo.preload(query,
      dashboard_components:
        {from(dc in DashboardComponent, order_by: dc.sequence),
         [[component: [:configurations]], [configurations: [:configuration]]]}
    )
  end

  def preload_configurations_of_component(component) do
    component
    |> Repo.preload(configurations: [:configuration])
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
    Component
    |> Repo.all()
    |> Repo.preload(:configurations)
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

  def create_dashboard_component_and_configurations(attrs, configurations) do
    configurations_multi =
      configurations
      |> Enum.reduce(Ecto.Multi.new(), fn configuration, query ->
        query
        |> Ecto.Multi.run(
          "create_configuration_for_#{Map.get(configuration, "configuration_id")}",
          fn _,
             %{
               dashboard_component: %{
                 id: dashboard_component_id
               }
             } ->
            ComponentConfiguration.changeset(
              %ComponentConfiguration{},
              Map.put(configuration, "dashboard_component_id", dashboard_component_id)
            )
            |> Repo.insert()
          end
        )
      end)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:dashboard_component, fn _, changes ->
      %DashboardComponent{}
      |> DashboardComponent.changeset(attrs)
      |> Repo.insert()
    end)
    |> Ecto.Multi.append(configurations_multi)
    |> Repo.transaction()
  end

  def delete_dashboard_component(%DashboardComponent{} = dc) do
    components =
      from(d in DashboardComponent,
        where: d.dashboard_id == ^dc.dashboard_id,
        where: d.sequence > ^dc.sequence,
        order_by: d.sequence
      )
      |> Repo.all()

    resequence_multi =
      Enum.reduce(components, Ecto.Multi.new(), fn component, query ->
        query
        |> Ecto.Multi.update(
          "resequence_#{component.id}",
          DashboardComponent.changeset(component, %{sequence: component.sequence - 1})
        )
      end)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:delete, dc)
    |> Ecto.Multi.append(resequence_multi)
    |> Repo.transaction()
  end

  def get_max_sequence_for_dashboard(%Dashboard{id: did}) do
    Repo.one(
      from dc in DashboardComponent, where: dc.dashboard_id == ^did, select: max(dc.sequence)
    )
  end

  @doc """
  Reorder the sequencing of the components

  However, don't attempt to resequence the component if the new
  sequence number and the old are equal.
  """
  def reorder_component(%{sequence: sequence} = dc, sequence), do: {:ok, dc}

  def reorder_component(%DashboardComponent{} = dc, new_sequence) do
    {resequence_others_query, direction} =
      cond do
        # moving closer to 0
        dc.sequence >= new_sequence ->
          {from(d in DashboardComponent,
             where: d.dashboard_id == ^dc.dashboard_id,
             where: d.sequence >= ^new_sequence,
             where: d.sequence < ^dc.sequence,
             order_by: [desc: d.sequence]
           ), 1}

        # moving away from 0
        dc.sequence <= new_sequence ->
          {from(d in DashboardComponent,
             where: d.dashboard_id == ^dc.dashboard_id,
             where: d.sequence <= ^new_sequence,
             where: d.sequence > ^dc.sequence,
             order_by: [asc: d.sequence]
           ), -1}
      end

    resequence_others =
      resequence_others_query
      |> Repo.all()
      |> Enum.reduce(Ecto.Multi.new(), fn component, query ->
        query
        |> Ecto.Multi.update(
          "resequence_#{component.id}_from_#{component.sequence}_to_#{
            component.sequence + direction
          }",
          DashboardComponent.changeset(component, %{sequence: component.sequence + direction})
        )
      end)

    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :resequence_target_temp,
      DashboardComponent.changeset(dc, %{sequence: -1})
    )
    |> Ecto.Multi.append(resequence_others)
    |> Ecto.Multi.update(
      :resequence_target,
      DashboardComponent.changeset(dc, %{sequence: new_sequence})
    )
    |> Repo.transaction()
  end

  @doc """
  Returns the list of dashboard_component_configurations.

  ## Examples

      iex> list_dashboard_component_configurations()
      [%ComponentConfiguration{}, ...]

  """
  def list_dashboard_component_configurations do
    Repo.all(ComponentConfiguration)
  end

  @doc """
  Gets a single component_configuration.

  Raises `Ecto.NoResultsError` if the Component configuration does not exist.

  ## Examples

      iex> get_component_configuration!(123)
      %ComponentConfiguration{}

      iex> get_component_configuration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_component_configuration!(id), do: Repo.get!(ComponentConfiguration, id)

  @doc """
  Creates a component_configuration.

  ## Examples

      iex> create_component_configuration(%{field: value})
      {:ok, %ComponentConfiguration{}}

      iex> create_component_configuration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_component_configuration(attrs \\ %{}) do
    %ComponentConfiguration{}
    |> ComponentConfiguration.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a component_configuration.

  ## Examples

      iex> update_component_configuration(component_configuration, %{field: new_value})
      {:ok, %ComponentConfiguration{}}

      iex> update_component_configuration(component_configuration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_component_configuration(%ComponentConfiguration{} = component_configuration, attrs) do
    component_configuration
    |> ComponentConfiguration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a component_configuration.

  ## Examples

      iex> delete_component_configuration(component_configuration)
      {:ok, %ComponentConfiguration{}}

      iex> delete_component_configuration(component_configuration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_component_configuration(%ComponentConfiguration{} = component_configuration) do
    Repo.delete(component_configuration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking component_configuration changes.

  ## Examples

      iex> change_component_configuration(component_configuration)
      %Ecto.Changeset{data: %ComponentConfiguration{}}

  """
  def change_component_configuration(
        %ComponentConfiguration{} = component_configuration,
        attrs \\ %{}
      ) do
    ComponentConfiguration.changeset(component_configuration, attrs)
  end
end
