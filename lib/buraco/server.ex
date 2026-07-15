defmodule Buraco.Server do
  use GenServer

  @moduledoc """
    GenServer responsibable for maintaining the in-memory key-value store.
  """

  @doc """
  Starts the key-value store process.

  The process is registered using the `Buraco.Server` module name.
  """

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Returns the value associated with `key`.

  Returns `nil` when the key does not exist.
  """
  @spec get(term()) :: term() | nil
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @doc """
  Stores `value` under `key` asynchronously.

  Returns `:ok`after sending the request to the server.
  """
  @spec put(term(), term()) :: :ok
  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  @spec delete(term()) :: :ok
  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
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
end
