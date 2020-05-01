defmodule Dashboard.Stores.ComponentStore do
  use GenServer

  @poll_interval 20_000

  require Logger

  def start_link(opts \\ []) do
    opts = Keyword.merge([name: __MODULE__], opts)
    GenServer.start_link(__MODULE__, %{component: opts[:component], user: opts[:user]}, opts)
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
      |> Map.put(state.component.assign, [])
      |> Map.put(:subscribers, [])
      |> Map.put(:timer, timer)

    {:ok, state}
  end

  def handle_call({:get, keyword}, _, state) do
    {:reply, Map.get(state, keyword, []), state}
  end

  def handle_call(:get_all, _, state) do
    {:reply, Map.get(state, state.component.assign, []), state}
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

  def handle_info(:update, state) do
    state =
      Map.put(
        state,
        state.component.assign,
        state.user
        |> Dashboard.PlanningCenterApi.Client.get(state.component.api_path)
        |> Map.get(:body, %{})
        |> Map.get("data", [])
      )

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

  # def terminate(reason, state) do
  #   :ok
  # end

  def terminate(reason, state) do
    :timer.cancel(state.timer)
    :ok
  end

  # ┌──────────────────┐
  # │ Helper Functions │
  # └──────────────────┘
end
