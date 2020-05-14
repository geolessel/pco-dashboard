defmodule Dashboard.Release do
  @app :dashboard
  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  def seed do
    load_app()

    Enum.each(@start_apps, &Application.ensure_all_started/1)

    Dashboard.Repo.start_link(pool_size: 1)

    path = Path.join(["#{:code.priv_dir(@app)}", "repo", "seeds.exs"])

    if File.exists?(path) do
      IO.puts("Running seed script at #{path} ...")
      Code.eval_file(path)
    end
  end

  def migrate do
    load_app()

    for repo <- repos() do
      IO.puts("migrating repo: #{Kernel.inspect(repo)}")
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
