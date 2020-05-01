defmodule Dashboard.Stores do
  def subscribe(name, subscriber_pid, component, user) do
    pid =
      case Dashboard.Stores.DynamicSupervisor.start_child(name, component, user) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    :ok = Dashboard.Stores.ComponentStore.subscribe(pid, subscriber_pid)
    {:ok, pid}
  end

  def unsubscribe(name, subscriber_pid) do
    Dashboard.Stores.ComponentStore.unsubscribe({:global, name}, subscriber_pid)
  end
end
