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
end
