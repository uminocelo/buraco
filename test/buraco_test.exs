defmodule BuracoTest do
  use ExUnit.Case, async: true

  setup do
    server_name = {:global, {__MODULE__, self(), make_ref()}}

    server =
      start_supervised!({Buraco.Server, name: server_name})

    %{server: server}
  end

  describe "put/3 and get/2" do
    test "put stores a new value", %{server: server} do
      assert :ok = Buraco.put(server, :language, "Elixir")
      assert Buraco.get(server, :language) == "Elixir"
    end

    test "get retrieves an existing value", %{server: server} do
      :ok = Buraco.put(server, :runtime, "BEAM")

      assert Buraco.get(server, :runtime) == "BEAM"
    end

    test "get returns nil for a missing key", %{server: server} do
      assert Buraco.get(server, :missing) == nil
    end

    test "put replaces an existing value", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :language, "Erlang")

      assert Buraco.get(server, :language) == "Erlang"
    end
  end

  describe "delete/2" do
    test "delete removes an existing value", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")

      assert Buraco.get(server, :language) == "Elixir"

      assert :ok = Buraco.delete(server, :language)
      assert Buraco.get(server, :language) == nil
    end

    test "delete handles a missing key", %{server: server} do
      :ok = Buraco.put(server, :keep, "preserved")

      assert :ok = Buraco.delete(server, :missing)
      assert Buraco.get(server, :missing) == nil
      assert Buraco.get(server, :keep) == "preserved"
    end
  end

  describe "put_async/3" do
    test "stores a value asynchronously", %{server: server} do
      assert :ok = Buraco.put_async(server, :language, "Elixir")

      assert Buraco.get(server, :language) == "Elixir"
    end
  end

  describe "key independence" do
    test "different keys remain independent", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :runtime, "BEAM")
      :ok = Buraco.put(server, :framework, "Phoenix")

      assert Buraco.get(server, :language) == "Elixir"
      assert Buraco.get(server, :runtime) == "BEAM"
      assert Buraco.get(server, :framework) == "Phoenix"

      :ok = Buraco.delete(server, :runtime)

      assert Buraco.get(server, :language) == "Elixir"
      assert Buraco.get(server, :runtime) == nil
      assert Buraco.get(server, :framework) == "Phoenix"
    end
  end

  describe "isolated" do
    test "isolated example", %{server: server} do
      :ok = Buraco.put(server, :shared_key, "first key")

      assert Buraco.get(server, :shared_key) == "first key"
    end

    test "second isolated example", %{server: server} do
      assert Buraco.get(server, :shared_key) == nil
    end
  end
end
