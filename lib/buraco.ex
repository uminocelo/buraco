defmodule Buraco do
  @moduledoc """
  An in-memory key-value store backed by GenServer.

  `Buraco` provides a small public apoi for storing, retriving and deleting values associated with keys.

  Keys and values maybe be any valid Elixir term.
  The data exists only in the memory of the `Buraco.Server` process. If that process stops or restarts, all stored data is lost.

  ## Usage
    Buraco.put(:language, "Elixir")
    Buraco.get(:language)
    Buraco.delete(:language)

  The `Buraco.Server` process must be running before these functions are used.
  """

  @type key :: term()
  @type value :: term()
  @type server :: GenServer.server()

  @doc """
  Stores `value` under `key`.

  This operation is asynchronus. Returning `:ok` means that the request was sent to the server, not necessarily that it has already been processed.

  An existing value under the same key is replaced.
  """
  @spec put(term(), term()) :: :ok
  def put(key, value) do
    put(Buraco.Server, key, value)
  end

  @doc """
  Stores `value` under `key` in the specified server.
  """
  @spec put(server(), key(), value()) :: :ok
  def put(server, key, value) do
    Buraco.Server.put(server, key, value)
  end

  @doc """
  Stores `value` under `key` asynchronously in the default server.

  Returning `:ok` does not represent server-side acknowledgement.
  """
  @spec put_async(key(), value()) :: :ok
  def put_async(key, value) do
    put_async(Buraco.Server, key, value)
  end

  @doc """
  Stores `value` under `key` asynchronously in the specified server.
  """
  @spec put_async(server(), key(), value()) :: :ok
  def put_async(server, key, value) do
    Buraco.Server.put_async(server, key, value)
  end

  @doc """
  Retrieves the value associated with `key`.
  Returns `nil` when the key does not exists.
  """
  @spec get(term()) :: term() | nil
  def get(key) do
    get(Buraco.Server, key)
  end

  @doc """
  Retrivies the value associated with `key` from the specified server.

  Returns `nil` when the key does not exists.
  """
  @spec get(server(), key()) :: term() | nil
  def get(server, key) do
    Buraco.Server.get(server, key)
  end

  @doc """
  Deletes the value associated with `key`.

  This operation is asynchronous. Deleting a key that does not exists leaves the store unchanged.
  """
  @spec delete(term()) :: :ok
  def delete(key) do
    delete(Buraco.Server, key)
  end

  @doc """
  Deletes `key` from specified server.
  """
  @spec delete(server(), key()) :: :ok
  def delete(server, key) do
    Buraco.Server.delete(server, key)
  end

  @doc """
  Returns whether `key` exists in the default store.
  """
  @spec has_key?(key()) :: boolean()
  def has_key?(key) do
    has_key?(Buraco.Server, key)
  end

  @doc """
  Returns whether `key` exists in the specified store.
  """
  @spec has_key?(server(), key()) :: boolean()
  def has_key?(server, key) do
    Buraco.Server.has_key?(server, key)
  end

  @doc """
  Returns the number of entries in the default store.
  """
  @spec size() :: non_neg_integer()
  def size do
    size(Buraco.Server)
  end

  @doc """
  Returns the number of entries in the specified store.
  """
  @spec size(server()) :: non_neg_integer()
  def size(server) do
    Buraco.Server.size(server)
  end

  @doc """
  Returns all keys in the default store.
  """
  @spec keys() :: [key()]
  def keys do
    keys(Buraco.Server)
  end

  @doc """
  Returns all keys in the specified store.
  """
  @spec keys(server()) :: [key()]
  def keys(server) do
    Buraco.Server.keys(server)
  end

  @doc """
  Returns all values in the default store.
  """
  @spec values() :: [value()]
  def values do
    values(Buraco.Server)
  end

  @doc """
  Returns all values in the specified store.
  """
  @spec values() :: [value()]
  def values(server) do
    Buraco.Server.values(server)
  end

  @doc """
  Returns all entries in the default store.
  """
  @spec get_all() :: %{optional(key()) => value()}
  def get_all do
    get_all(Buraco.Server)
  end

  @doc """
  Returns all entries in the specified store.
  """
  @spec get_all(server()) :: %{optional(key()) => value()}
  def get_all(server) do
    Buraco.Server.get_all(server)
  end

  @doc """
  Removes every entry from default store.
  """
  @spec clear() :: :ok
  def clear do
    clear(Buraco.Server)
  end

  @doc """
  Removes every entry from specified store.
  """
  @spec clear(server()) :: :ok
  def clear(server) do
    Buraco.Server.clear(server)
  end
end
