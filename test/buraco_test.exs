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

  describe "utility operations" do
    test "has_key? reports whether a key exists", %{server: server} do
      refute Buraco.has_key?(server, :language)
      :ok = Buraco.put(server, :language, "Elixir")

      assert Buraco.has_key?(server, :language)
      refute Buraco.has_key?(server, :missing)
    end

    test "has_key? recognizes a key storing nil", %{server: server} do
      :ok = Buraco.put(server, :answer, nil)

      assert Buraco.has_key?(server, :answer)
      assert nil == Buraco.get(server, :answer)
    end

    test "size returns the number of entries", %{server: server} do
      assert Buraco.size(server) == 0

      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :runtime, "BEAM")

      assert Buraco.size(server) == 2
    end

    test "overwriting a key does not increase size", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :language, "Erlang")

      assert Buraco.size(server) == 1
    end

    test "keys returns all stored keys", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :runtime, "BEAM")
      :ok = Buraco.put(server, {:user, 1}, "Celo")

      assert MapSet.new(Buraco.keys(server)) == MapSet.new([:language, :runtime, {:user, 1}])
    end

    test "values returns all stored values", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :runtime, "BEAM")

      assert Enum.sort(Buraco.values(server)) == Enum.sort(["Elixir", "BEAM"])
    end

    test "values preserves duplicate values", %{server: server} do
      :ok = Buraco.put(server, :first, "Elixir")
      :ok = Buraco.put(server, :favorite, "Elixir")

      assert Buraco.values(server) == ["Elixir", "Elixir"]
    end

    test "get_all returns all entries", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :runtime, "BEAM")

      assert Buraco.get_all(server) == %{language: "Elixir", runtime: "BEAM"}
    end

    test "clear removes every entry", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :runtime, "BEAM")

      assert Buraco.size(server) == 2
      assert :ok = Buraco.clear(server)

      assert Buraco.size(server) == 0
      assert Buraco.keys(server) == []
      assert Buraco.values(server) == []
      assert Buraco.get_all(server) == %{}
      assert nil == Buraco.get(server, :language)
      assert nil == Buraco.get(server, :runtime)
    end

    test "clearing an empty store succeeds", %{server: server} do
      assert :ok = Buraco.clear(server)
      assert Buraco.get_all(server) == %{}
    end

    test "read-only utility operations do not change entries", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")
      :ok = Buraco.put(server, :runtime, "BEAM")

      assert Buraco.has_key?(server, :language)
      assert Buraco.size(server) == 2
      assert MapSet.new(Buraco.keys(server)) == MapSet.new([:language, :runtime])
      assert Enum.sort(Buraco.values(server)) == Enum.sort(["Elixir", "BEAM"])

      assert Buraco.get_all(server) == %{
               language: "Elixir",
               runtime: "BEAM"
             }

      assert "Elixir" = Buraco.get(server, :language)
      assert "BEAM" = Buraco.get(server, :runtime)
      assert Buraco.size(server) == 2
    end
  end

  describe "unexpected messages" do
    test "preserves state and keeps the server alive", %{server: server} do
      :ok = Buraco.put(server, :language, "Elixir")

      send(server, {:unexpected, :hello})

      assert "Elixir" = Buraco.get(server, :language)
      assert Process.alive?(server)
      assert Buraco.size(server) == 1
    end
  end
end
