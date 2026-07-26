defmodule Buraco.Server do
  @moduledoc """
    GenServer responsibable for maintaining the in-memory key-value store.
  """

  use GenServer

  require Logger

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
    GenServer.call(server, {:put, key, value})
  end

  @doc """
  Stores `value` under `key` asynchronously using the default server.

  Returning `:ok` does not mean that server has already processed the write.
  """
  @spec put_async(term(), term()) :: :ok
  def put_async(key, value) do
    put_async(__MODULE__, key, value)
  end

  @doc """
  Stores `value` under `key` asynchronously using `server`.
  """
  @spec put_async(server(), term(), term()) :: :ok
  def put_async(server, key, value) do
    GenServer.cast(server, {:put_async, key, value})
  end

  @doc """
  Deletes the value associated with `key` asynchronously.

  Deleting a key that does not exist leaves the store unchanged.
  """
  @spec delete(term()) :: :ok
  def delete(key) do
    delete(__MODULE__, key)
  end

  @doc """
  Deletes `key` from `server`.

  The function returns `:ok` after the server processes the deletion.
  """
  @spec delete(server(), term()) :: :ok
  def delete(server, key) do
    GenServer.call(server, {:delete, key})
  end

  @doc """
  Returns `key` exists in the default server.
  """
  @spec has_key?(term()) :: boolean()
  def has_key?(key) do
    has_key?(__MODULE__, key)
  end

  @doc """
  Return whether `key` exists in `server`.
  """
  @spec has_key?(server(), term()) :: boolean()
  def has_key?(server, key) do
    GenServer.call(server, {:has_key?, key})
  end

  @doc """
  Returns the number of entries in the default server.
  """
  @spec size() :: non_neg_integer()
  def size do
    size(__MODULE__)
  end

  @doc """
  Returns the number of entries server.
  """
  @spec size(server()) :: non_neg_integer()
  def size(server) do
    GenServer.call(server, :size)
  end

  @doc """
  Retruns all keys from the default server
  """
  @spec keys() :: [term()]
  def keys do
    keys(__MODULE__)
  end

  @doc """
  Returns all keys from server.
  """
  @spec keys(server()) :: [term()]
  def keys(server) do
    GenServer.call(server, :keys)
  end

  @doc """
  Returns all values from the default server.
  """
  @spec values() :: [term()]
  def values do
    values(__MODULE__)
  end

  @doc """
  Returns all values from the server.
  """
  @spec values(server()) :: [term()]
  def values(server) do
    GenServer.call(server, :values)
  end

  @doc """
  Returns all entries from default server
  """
  @spec get_all() :: map()
  def get_all do
    get_all(__MODULE__)
  end

  @doc """
  Returns all entries from server
  """
  @spec get_all(server()) :: map()
  def get_all(server) do
    GenServer.call(server, :get_all)
  end

  @doc """
  Removes every entry from default server
  """
  @spec clear() :: :ok
  def clear do
    clear(__MODULE__)
  end

  @doc """
  Removes every entry from server
  """
  @spec clear(server()) :: :ok
  def clear(server) do
    GenServer.call(server, :clear)
  end

  @impl true
  def init(initial_state) do
    Logger.metadata(component: :buraco_server)

    Logger.info("Buraco.Server initialized", initial_state: map_size(initial_state))

    {:ok, initial_state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    value = Map.get(state, key)

    {:reply, value, state}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    new_state = Map.put(state, key, value)

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:delete, key}, _from, state) do
    new_state = Map.delete(state, key)

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:has_key?, key}, _from, state) do
    exists? = Map.has_key?(state, key)

    {:reply, exists?, state}
  end

  @impl true
  def handle_call(:size, _from, state) do
    {:reply, map_size(state), state}
  end

  @impl true
  def handle_call(:keys, _from, state) do
    keys = Map.keys(state)

    {:reply, keys, state}
  end

  @impl true
  def handle_call(:values, _from, state) do
    values = Map.values(state)

    {:reply, values, state}
  end

  @impl true
  def handle_call(:get_all, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:clear, _from, state) do
    previous_size = map_size(state)
    Logger.info("Buraco store cleared", previous_size: previous_size)

    {:reply, :ok, %{}}
  end

  @impl true
  def handle_cast({:put_async, key, value}, state) do
    new_state = Map.put(state, key, value)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.warning(fn ->
      "Buraco.Server received an unexpected message" <>
        inspect(message, limit: 20, printable_limit: 200)
    end)

    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info(fn ->
      "Buraco.Server terminating: " <>
        "reason=#{inspect(reason)}" <>
        "size=#{map_size(state)}"
    end)

    :ok
  end
end
