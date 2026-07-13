defmodule BuracoTest do
  use ExUnit.Case
  doctest Buraco

  test "greets the world" do
    assert Buraco.hello() == :world
  end
end
