defmodule Dashboard.ApiClient do
  use GenServer
  alias Dashboard.Accounts.User

  require Logger

  defstruct [:conn, requests: %{}]

  def start_link({scheme, host, port, opts}) do
    GenServer.start_link(__MODULE__, {scheme, host, port}, opts)
  end

  def get(pid, %User{} = as_user, path) do
    GenServer.call(
      pid,
      {:request, "GET", path, headers(as_user), nil},
      20_000
    )
  end

  def request(pid, method, path, headers, body) do
    GenServer.call(pid, {:request, method, path, headers, body}, 20_000)
  end

  def open?(pid) do
    GenServer.call(pid, :open?)
  end

  ## Callbacks

  @impl true
  def init({scheme, host, port}) do
    # TODO: maybe keep the connection in a Process and spawn a process for each request
    case Mint.HTTP.connect(scheme, host, port) do
      {:ok, conn} ->
        state = %__MODULE__{conn: conn}
        {:ok, state}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_call({:request, method, path, headers, body}, from, state) do
    # In both the successful case and the error case, we make sure to update the connection
    # struct in the state since the connection is an immutable data structure.
    case Mint.HTTP.request(state.conn, method, path, headers, body) do
      {:ok, conn, request_ref} ->
        state = put_in(state.conn, conn)
        # We store the caller this request belongs to and an empty map as the response.
        # The map will be filled with status code, headers, and so on.
        state = put_in(state.requests[request_ref], %{from: from, response: %{}})
        {:noreply, state}

      {:error, conn, %{reason: :closed}} ->
        {:stop, :normal, state}

      {:error, conn, reason} ->
        state = put_in(state.conn, conn)
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:open?, _, state) do
    {:reply, Mint.HTTP.open?(state.conn), state}
  end

  def handle_info({:ssl_closed, _}, state) do
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state) do
    Logger.debug("closing unused ApiClient genserver")
    {:stop, :normal, state}
  end

  @impl true
  def handle_info(message, state) do
    # We should handle the error case here as well, but we're omitting it for brevity.
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        _ = Logger.error(fn -> "Received unknown message: " <> inspect(message) end)
        {:noreply, state}

      {:error, conn, response} ->
        Logger.error(fn -> "Received error: " <> inspect(conn) end)
        {:noreply, state}

      {:ok, conn, responses} ->
        state = put_in(state.conn, conn)
        state = Enum.reduce(responses, state, &process_response/2)
        {:noreply, state}
    end
  end

  defp process_response({:status, request_ref, status}, state) do
    put_in(state.requests[request_ref].response[:status], status)
  end

  defp process_response({:headers, request_ref, headers}, state) do
    put_in(state.requests[request_ref].response[:headers], headers)
  end

  defp process_response({:data, request_ref, new_data}, state) do
    update_in(state.requests[request_ref].response[:data], fn data -> (data || "") <> new_data end)
  end

  # When the request is done, we use GenServer.reply/2 to reply to the caller that was
  # blocked waiting on this request.
  defp process_response({:done, request_ref}, state) do
    {%{response: response, from: from}, state} = pop_in(state.requests[request_ref])
    GenServer.reply(from, {:ok, response})
    state
  end

  defp headers(auth) do
    []
    |> content_header()
    |> auth_header(auth)
  end

  defp content_header(headers) do
    [{"Content-Type", "application/json"} | headers]
  end

  defp auth_header(headers, %{
         application_id: application_id,
         application_secret: application_secret
       }) do
    credentials =
      (application_id <> ":" <> application_secret)
      |> Base.encode64()

    [{"Authorization", "Basic #{credentials}"} | headers]
  end

  defp auth_header(headers, %{token: token}) do
    [{"Authorization", "Bearer #{token}"} | headers]
  end
end
