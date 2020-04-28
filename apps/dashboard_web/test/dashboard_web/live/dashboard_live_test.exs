defmodule DashboardWeb.DashboardLiveTest do
  use DashboardWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Dashboard.Dashboards

  @create_attrs %{name: "some name", slug: "some slug"}
  @update_attrs %{name: "some updated name", slug: "some updated slug"}
  @invalid_attrs %{name: nil, slug: nil}

  defp fixture(:dashboard) do
    {:ok, dashboard} = Dashboards.create_dashboard(@create_attrs)
    dashboard
  end

  defp create_dashboard(_) do
    dashboard = fixture(:dashboard)
    %{dashboard: dashboard}
  end

  describe "Index" do
    setup [:create_dashboard]

    test "lists all dashboards", %{conn: conn, dashboard: dashboard} do
      {:ok, _index_live, html} = live(conn, Routes.dashboard_index_path(conn, :index))

      assert html =~ "Listing Dashboards"
      assert html =~ dashboard.name
    end

    test "saves new dashboard", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.dashboard_index_path(conn, :index))

      assert index_live |> element("a", "New Dashboard") |> render_click() =~
        "New Dashboard"

      assert_patch(index_live, Routes.dashboard_index_path(conn, :new))

      assert index_live
             |> form("#dashboard-form", dashboard: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#dashboard-form", dashboard: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.dashboard_index_path(conn, :index))

      assert html =~ "Dashboard created successfully"
      assert html =~ "some name"
    end

    test "updates dashboard in listing", %{conn: conn, dashboard: dashboard} do
      {:ok, index_live, _html} = live(conn, Routes.dashboard_index_path(conn, :index))

      assert index_live |> element("#dashboard-#{dashboard.id} a", "Edit") |> render_click() =~
        "Edit Dashboard"

      assert_patch(index_live, Routes.dashboard_index_path(conn, :edit, dashboard))

      assert index_live
             |> form("#dashboard-form", dashboard: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#dashboard-form", dashboard: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.dashboard_index_path(conn, :index))

      assert html =~ "Dashboard updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes dashboard in listing", %{conn: conn, dashboard: dashboard} do
      {:ok, index_live, _html} = live(conn, Routes.dashboard_index_path(conn, :index))

      assert index_live |> element("#dashboard-#{dashboard.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#dashboard-#{dashboard.id}")
    end
  end

  describe "Show" do
    setup [:create_dashboard]

    test "displays dashboard", %{conn: conn, dashboard: dashboard} do
      {:ok, _show_live, html} = live(conn, Routes.dashboard_show_path(conn, :show, dashboard))

      assert html =~ "Show Dashboard"
      assert html =~ dashboard.name
    end

    test "updates dashboard within modal", %{conn: conn, dashboard: dashboard} do
      {:ok, show_live, _html} = live(conn, Routes.dashboard_show_path(conn, :show, dashboard))

      assert show_live |> element("a", "Edit") |> render_click() =~
        "Edit Dashboard"

      assert_patch(show_live, Routes.dashboard_show_path(conn, :edit, dashboard))

      assert show_live
             |> form("#dashboard-form", dashboard: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#dashboard-form", dashboard: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.dashboard_show_path(conn, :show, dashboard))

      assert html =~ "Dashboard updated successfully"
      assert html =~ "some updated name"
    end
  end
end
