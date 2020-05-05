defmodule Dashboard.Stores do
  def subscribe(module, name, subscriber_pid, component, user) do
    pid =
      case Dashboard.Stores.DynamicSupervisor.start_child(module, name, component, user) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    :ok = module.subscribe(pid, subscriber_pid)
    {:ok, pid}
  end

  def unsubscribe(module, name, subscriber_pid) do
    module.unsubscribe({:global, name}, subscriber_pid)
  end

  def get(module, name, keyword, default \\ nil) do
    case module.get({:global, name}, keyword) do
      nil -> default
      val -> val
    end
  end
end
