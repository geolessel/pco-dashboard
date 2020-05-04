defmodule Dashboard.Stores.ComponentStore do
  use GenServer

  @poll_interval 20_000

  require Logger

  def start_link(opts \\ []) do
    opts = Keyword.merge([name: __MODULE__], opts)

    GenServer.start_link(
      __MODULE__,
      %{dashboard_component: opts[:component], user: opts[:user]},
      opts
    )
  end

  def subscribe(pid, subscriber_pid) do
    GenServer.cast(pid, {:subscribe, subscriber_pid})
  end

  def unsubscribe(pid, subscriber_pid) do
    GenServer.cast(pid, {:unsubscribe, subscriber_pid})
  end

  def get(pid, keyword) do
    GenServer.call(pid, {:get, keyword})
  end

  def get_all(pid) do
    GenServer.call(pid, :get_all)
  end

  def cancel_updates(pid) do
    GenServer.cast(pid, :cancel_updates)
  end

  def inspect(pid) do
    GenServer.call(pid, :inspect)
  end

  # ┌──────────────────┐
  # │ Server Callbacks │
  # └──────────────────┘

  def init(state) do
    {:ok, timer} = :timer.send_interval(@poll_interval, :update)

    state =
      state
      |> Map.put(state.dashboard_component.component.assign, [])
      |> Map.put(:component, state.dashboard_component.component)
      |> Map.put(:subscribers, [])
      |> Map.put(:last_response, %Dashboard.PlanningCenterApi.Response{})
      |> Map.put(:last_update, nil)
      |> Map.put(:timer, timer)

    {:ok, state}
  end

  def handle_call({:get, keyword}, _, state) do
    {:reply, Map.get(state, keyword), state}
  end

  def handle_call(:get_all, _, state) do
    {:reply, Map.get(state, state.component.assign), state}
  end

  def handle_call(:inspect, _, state) do
    {:reply, state, state}
  end

  def handle_cast(:cancel_updates, %{timer: nil} = state), do: {:noreply, state}

  def handle_cast(:cancel_updates, %{timer: timer} = state) do
    :timer.cancel(timer)
    {:noreply, %{state | timer: nil}}
  end

  def handle_cast({:subscribe, subscriber_pid}, %{subscribers: subscribers} = state) do
    Process.monitor(subscriber_pid)

    subscribers =
      [subscriber_pid | subscribers]
      |> Enum.uniq()

    Logger.debug(
      "New subscriber (#{Kernel.inspect(subscriber_pid)}) to #{Kernel.inspect(self())}. #{
        Kernel.inspect(subscribers)
      }"
    )

    maybe_update_immediately(state.last_update)

    {:noreply, %{state | subscribers: subscribers}}
  end

  def handle_cast({:unsubscribe, subscriber_pid}, %{subscribers: subscribers} = state) do
    subscribers =
      subscribers
      |> Enum.filter(fn subscriber ->
        subscriber != subscriber_pid
      end)

    Logger.debug(
      "Removed subscriber (#{Kernel.inspect(subscriber_pid)}) from #{Kernel.inspect(self())}. #{
        Kernel.inspect(subscribers)
      }"
    )

    {:noreply, %{state | subscribers: subscribers}}
  end

  @doc """
  Fetch updates from the Planning Center API.

  Also handles letting subscribers know there is new data to enjoy.

  If there are no subscribers, don't bother making the request.
  """
  def handle_info(:update, %{subscribers: subscribers} = state) when length(subscribers) == 0,
    do: {:noreply, state}

  def handle_info(:update, state) do
    path = prepare_api_path(state.dashboard_component)

    response =
      state.user
      |> Dashboard.PlanningCenterApi.Client.get(path)
      |> Map.get(:body, %{})

    state =
      state
      |> Map.put(
        state.component.assign,
        Map.get(response, "data", [])
      )
      |> Map.put(:last_response, response)
      |> Map.put(:last_update, DateTime.utc_now())

    state.subscribers
    |> Enum.each(fn subscriber ->
      Process.send(subscriber, :tell_components_to_update, [])
    end)

    {:noreply, state}
  end

  @doc """
  Unsubscribe a subscribed process when it goes down

  We receive this message because we previously used `Process.monitor/1`
  to monitor the process. If the process has already been subscribed (because
  the LiveView handled the termination, for example), this could result
  in two calls to `unsubscribe/2`, but I don't think that is a big deal.
  """
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    __MODULE__.unsubscribe(self(), pid)
    {:noreply, state}
  end

  def terminate(_reason, state) do
    :timer.cancel(state.timer)
    :ok
  end

  # ┌──────────────────┐
  # │ Helper Functions │
  # └──────────────────┘

  def maybe_update_immediately(nil), do: send(self(), :update)

  def maybe_update_immediately(last_update) do
    if DateTime.diff(DateTime.utc_now(), last_update) > @poll_interval do
      send(self(), :update)
    else
      :ok
    end
  end

  def prepare_api_path(component) do
    component
    |> Dashboard.Dashboards.preload_configurations_of_component()
    |> Map.get(:configurations, [])
    |> Enum.reduce(component.component.api_path, fn %{configuration: %{name: name}, value: value},
                                                    path ->
      String.replace(path, "${#{name}}", value)
    end)
  end
end
