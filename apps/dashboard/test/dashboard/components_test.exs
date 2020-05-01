defmodule Dashboard.ComponentsTest do
  use Dashboard.DataCase

  alias Dashboard.Components

  describe "configurations" do
    alias Dashboard.Components.Configuration

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def configuration_fixture(attrs \\ %{}) do
      {:ok, configuration} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Components.create_configuration()

      configuration
    end

    test "list_configurations/0 returns all configurations" do
      configuration = configuration_fixture()
      assert Components.list_configurations() == [configuration]
    end

    test "get_configuration!/1 returns the configuration with given id" do
      configuration = configuration_fixture()
      assert Components.get_configuration!(configuration.id) == configuration
    end

    test "create_configuration/1 with valid data creates a configuration" do
      assert {:ok, %Configuration{} = configuration} = Components.create_configuration(@valid_attrs)
      assert configuration.name == "some name"
    end

    test "create_configuration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Components.create_configuration(@invalid_attrs)
    end

    test "update_configuration/2 with valid data updates the configuration" do
      configuration = configuration_fixture()
      assert {:ok, %Configuration{} = configuration} = Components.update_configuration(configuration, @update_attrs)
      assert configuration.name == "some updated name"
    end

    test "update_configuration/2 with invalid data returns error changeset" do
      configuration = configuration_fixture()
      assert {:error, %Ecto.Changeset{}} = Components.update_configuration(configuration, @invalid_attrs)
      assert configuration == Components.get_configuration!(configuration.id)
    end

    test "delete_configuration/1 deletes the configuration" do
      configuration = configuration_fixture()
      assert {:ok, %Configuration{}} = Components.delete_configuration(configuration)
      assert_raise Ecto.NoResultsError, fn -> Components.get_configuration!(configuration.id) end
    end

    test "change_configuration/1 returns a configuration changeset" do
      configuration = configuration_fixture()
      assert %Ecto.Changeset{} = Components.change_configuration(configuration)
    end
  end
end
