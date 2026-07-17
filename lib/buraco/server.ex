defmodule Buraco.Server do
  use GenServer

  @moduledoc """
    GenServer responsibable for maintaining the in-memory key-value store.
  """

  @type server :: GenServer.server()

  @doc """
  Starts the key-value store process.

  The process is registered using the `Buraco.Server` module name.
  """

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)

    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @doc """
  Returns the value associated with `key`.

  Returns `nil` when the key does not exist.
  """
  @spec get(term()) :: term() | nil
  def get(key) do
    get(__MODULE__, key)
  end

  @spec get(server(), term()) :: term() | nil
  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  @doc """
  Stores `value` under `key` asynchronously.

  Returns `:ok`after sending the request to the server.
  """
  @spec put(term(), term()) :: :ok
  def put(key, value) do
    put(__MODULE__, key, value)
  end

  @spec put(server(), term(), term()) :: :ok
  def put(server, key, value) do
    GenServer.cast(server, {:put, key, value})
  end

  @doc """
  Deletes the value associated with `key` asynchronously.

  Deleting a key that does not exist leaves the store unchanged.
  """
  @spec delete(term()) :: :ok
  def delete(key) do
    delete(__MODULE__, key)
  end

  @spec delete(server(), term()) :: :ok
  def delete(server, key) do
    GenServer.cast(server, {:delete, key})
  end

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    value = Map.get(state, key)

    {:reply, value, state}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    new_state = Map.put(state, key, value)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    new_state = Map.delete(state, key)

    {:noreply, new_state}
  end
end
