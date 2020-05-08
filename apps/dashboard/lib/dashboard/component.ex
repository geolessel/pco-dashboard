defmodule Dashboard.Component do
  defmacro __using__(_opts) do
    quote do
      use GenServer, restart: :transient
      require Logger

      @poll_interval 20_000
      # 10 minutes
      @ttl_seconds 10 * 60 * 1_000

      @behaviour Dashboard.Behaviours.Component

      def start_link(opts \\ []) do
        opts = Keyword.merge([name: __MODULE__], opts)

        {:global, name} = opts[:name]

        GenServer.start_link(
          __MODULE__,
          %{dashboard_component: opts[:component], user: opts[:user], name: name},
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
        {:ok, update_timer} = :timer.send_interval(@poll_interval, :update)

        state =
          state
          |> Map.put(:component, state.dashboard_component.component)
          |> Map.put(:subscribers, [])
          |> Map.put(:last_response, %Dashboard.PlanningCenterApi.Response{})
          |> Map.put(:last_update, nil)
          |> Map.put(:update_timer, update_timer)

        {:ok, state}
      end

      def handle_call({:get, keyword}, _, state) do
        {:reply, Map.get(state, keyword), state}
      end

      def handle_call(:get_all, _, state) do
        {:reply, state, state}
      end

      def handle_call(:inspect, _, state) do
        {:reply, state, state}
      end

      def handle_cast(:cancel_updates, %{update_timer: nil} = state), do: {:noreply, state}

      def handle_cast(:cancel_updates, %{update_timer: update_timer} = state) do
        :timer.cancel(update_timer)
        {:noreply, %{state | update_timer: nil}}
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

      If there are no subscribers, don't bother making the request. If there are no subscribers
      and it's been a set amount of time, kill the genserver.
      """
      def handle_info(:update, %{subscribers: subscribers, last_update: last_update} = state)
          when length(subscribers) == 0 and not is_nil(last_update) do
        if DateTime.diff(DateTime.utc_now(), last_update) > @ttl_seconds do
          Logger.debug(
            "shutting down GenServer: #{state.name}. It's been #{@ttl_seconds} seconds and no one's listening."
          )

          {:stop, :normal, state}
        else
          {:noreply, state}
        end
      end

      def handle_info(:update, state) do
        state =
          state
          |> maybe_refresh_oauth_token()
          |> fetch_data()
          |> process_data()
          |> put_last_update()
          |> put_extra_assigns()

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
        Logger.debug("canceling update timer of #{state.name}")
        {:ok, cancel} = :timer.cancel(state.update_timer)
        :ok
      end

      # ┌──────────────────┐
      # │ Helper Functions │
      # └──────────────────┘

      def fetch_data(%{user: user} = state) do
        Map.merge(
          state,
          data_sources()
          |> prepare_api_paths(state)
          |> Enum.map(fn {assign, path} ->
            Task.async(fn -> {assign, Dashboard.PlanningCenterApi.Client.get(user, path)} end)
          end)
          |> Enum.map(&Task.await/1)
          |> Enum.into(%{})
        )
      end

      def maybe_refresh_oauth_token(%{user: user} = state) do
        # TODO: Since these are per-component, there could be race conditions!
        with :oauth <- Application.get_env(:dashboard, :auth_type),
             token <- Dashboard.Accounts.get_oauth_token_of_user!(user),
             :lt <-
               NaiveDateTime.compare(token.expires_at, NaiveDateTime.utc_now()) do
          attrs =
            Dashboard.PlanningCenterApi.Oauth.refresh!(token.refresh_token)
            |> Dashboard.PlanningCenterApi.Oauth.to_db_attrs()
            |> Map.put(:user_id, user.id)

          Dashboard.Accounts.update_oauth_token(token, attrs)

          Map.put(state, :user, Dashboard.Accounts.get_user!(user.id))
        else
          :gt -> state
        end
      end

      def maybe_update_immediately(nil), do: send(self(), :update)

      def maybe_update_immediately(last_update) do
        if DateTime.diff(DateTime.utc_now(), last_update) > @poll_interval do
          send(self(), :update)
        else
          :ok
        end
      end

      def prepare_api_paths(sources, %{dashboard_component: component} = state) do
        configs =
          component
          |> Dashboard.Dashboards.preload_configurations_of_component()
          |> Map.get(:configurations, [])

        sources
        |> Enum.reduce(sources, fn {key, path}, acc ->
          Map.update(acc, key, path, &replace_config_values(&1, configs))
        end)
      end

      def replace_config_values(path, configs) do
        Enum.reduce(configs, path, fn %{
                                        configuration: %{name: name},
                                        value: value
                                      },
                                      path ->
          String.replace(path, "${#{name}}", value)
        end)
      end

      def put_extra_assigns(state), do: state

      def put_last_update(state), do: Map.put(state, :last_update, DateTime.utc_now())

      defoverridable Dashboard.Behaviours.Component
    end
  end
end
