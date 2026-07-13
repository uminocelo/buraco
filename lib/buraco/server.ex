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

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end
end
