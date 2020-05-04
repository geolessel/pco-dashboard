defmodule Dashboard.DashboardsTest do
  use Dashboard.DataCase

  alias Dashboard.Dashboards

  describe "dashboards" do
    alias Dashboard.Dashboards.Dashboard

    @valid_attrs %{name: "some name", slug: "some slug"}
    @update_attrs %{name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{name: nil, slug: nil}

    def dashboard_fixture(attrs \\ %{}) do
      {:ok, dashboard} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboards.create_dashboard()

      dashboard
    end

    test "list_dashboards/0 returns all dashboards" do
      dashboard = dashboard_fixture()
      assert Dashboards.list_dashboards() == [dashboard]
    end

    test "get_dashboard!/1 returns the dashboard with given id" do
      dashboard = dashboard_fixture()
      assert Dashboards.get_dashboard!(dashboard.id) == dashboard
    end

    test "create_dashboard/1 with valid data creates a dashboard" do
      assert {:ok, %Dashboard{} = dashboard} = Dashboards.create_dashboard(@valid_attrs)
      assert dashboard.name == "some name"
      assert dashboard.slug == "some slug"
    end

    test "create_dashboard/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboards.create_dashboard(@invalid_attrs)
    end

    test "update_dashboard/2 with valid data updates the dashboard" do
      dashboard = dashboard_fixture()
      assert {:ok, %Dashboard{} = dashboard} = Dashboards.update_dashboard(dashboard, @update_attrs)
      assert dashboard.name == "some updated name"
      assert dashboard.slug == "some updated slug"
    end

    test "update_dashboard/2 with invalid data returns error changeset" do
      dashboard = dashboard_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboards.update_dashboard(dashboard, @invalid_attrs)
      assert dashboard == Dashboards.get_dashboard!(dashboard.id)
    end

    test "delete_dashboard/1 deletes the dashboard" do
      dashboard = dashboard_fixture()
      assert {:ok, %Dashboard{}} = Dashboards.delete_dashboard(dashboard)
      assert_raise Ecto.NoResultsError, fn -> Dashboards.get_dashboard!(dashboard.id) end
    end

    test "change_dashboard/1 returns a dashboard changeset" do
      dashboard = dashboard_fixture()
      assert %Ecto.Changeset{} = Dashboards.change_dashboard(dashboard)
    end
  end

  describe "components" do
    alias Dashboard.Dashboards.Component

    @valid_attrs %{api_path: "some api_path", assign: "some assign", module: "some module", name: "some name"}
    @update_attrs %{api_path: "some updated api_path", assign: "some updated assign", module: "some updated module", name: "some updated name"}
    @invalid_attrs %{api_path: nil, assign: nil, module: nil, name: nil}

    def component_fixture(attrs \\ %{}) do
      {:ok, component} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboards.create_component()

      component
    end

    test "list_components/0 returns all components" do
      component = component_fixture()
      assert Dashboards.list_components() == [component]
    end

    test "get_component!/1 returns the component with given id" do
      component = component_fixture()
      assert Dashboards.get_component!(component.id) == component
    end

    test "create_component/1 with valid data creates a component" do
      assert {:ok, %Component{} = component} = Dashboards.create_component(@valid_attrs)
      assert component.api_path == "some api_path"
      assert component.assign == "some assign"
      assert component.module == "some module"
      assert component.name == "some name"
    end

    test "create_component/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboards.create_component(@invalid_attrs)
    end

    test "update_component/2 with valid data updates the component" do
      component = component_fixture()
      assert {:ok, %Component{} = component} = Dashboards.update_component(component, @update_attrs)
      assert component.api_path == "some updated api_path"
      assert component.assign == "some updated assign"
      assert component.module == "some updated module"
      assert component.name == "some updated name"
    end

    test "update_component/2 with invalid data returns error changeset" do
      component = component_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboards.update_component(component, @invalid_attrs)
      assert component == Dashboards.get_component!(component.id)
    end

    test "delete_component/1 deletes the component" do
      component = component_fixture()
      assert {:ok, %Component{}} = Dashboards.delete_component(component)
      assert_raise Ecto.NoResultsError, fn -> Dashboards.get_component!(component.id) end
    end

    test "change_component/1 returns a component changeset" do
      component = component_fixture()
      assert %Ecto.Changeset{} = Dashboards.change_component(component)
    end
  end

  describe "dashboard_component_configurations" do
    alias Dashboard.Dashboards.ComponentConfiguration

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def component_configuration_fixture(attrs \\ %{}) do
      {:ok, component_configuration} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dashboards.create_component_configuration()

      component_configuration
    end

    test "list_dashboard_component_configurations/0 returns all dashboard_component_configurations" do
      component_configuration = component_configuration_fixture()
      assert Dashboards.list_dashboard_component_configurations() == [component_configuration]
    end

    test "get_component_configuration!/1 returns the component_configuration with given id" do
      component_configuration = component_configuration_fixture()
      assert Dashboards.get_component_configuration!(component_configuration.id) == component_configuration
    end

    test "create_component_configuration/1 with valid data creates a component_configuration" do
      assert {:ok, %ComponentConfiguration{} = component_configuration} = Dashboards.create_component_configuration(@valid_attrs)
    end

    test "create_component_configuration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboards.create_component_configuration(@invalid_attrs)
    end

    test "update_component_configuration/2 with valid data updates the component_configuration" do
      component_configuration = component_configuration_fixture()
      assert {:ok, %ComponentConfiguration{} = component_configuration} = Dashboards.update_component_configuration(component_configuration, @update_attrs)
    end

    test "update_component_configuration/2 with invalid data returns error changeset" do
      component_configuration = component_configuration_fixture()
      assert {:error, %Ecto.Changeset{}} = Dashboards.update_component_configuration(component_configuration, @invalid_attrs)
      assert component_configuration == Dashboards.get_component_configuration!(component_configuration.id)
    end

    test "delete_component_configuration/1 deletes the component_configuration" do
      component_configuration = component_configuration_fixture()
      assert {:ok, %ComponentConfiguration{}} = Dashboards.delete_component_configuration(component_configuration)
      assert_raise Ecto.NoResultsError, fn -> Dashboards.get_component_configuration!(component_configuration.id) end
    end

    test "change_component_configuration/1 returns a component_configuration changeset" do
      component_configuration = component_configuration_fixture()
      assert %Ecto.Changeset{} = Dashboards.change_component_configuration(component_configuration)
    end
  end
end
