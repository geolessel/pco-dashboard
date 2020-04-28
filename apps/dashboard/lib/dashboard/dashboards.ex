defmodule Dashboard.Dashboards do
  @moduledoc """
  The Dashboards context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.Dashboards.Dashboard

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
  def get_dashboard!(id, user_id), do: Repo.get_by!(Dashboard, %{id: id, user_id: user_id})

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
    Repo.get_by!(Dashboard, %{slug: slug, user_id: user_id})
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
end
