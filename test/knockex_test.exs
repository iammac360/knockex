defmodule KnockexTest do
  use ExUnit.Case
  doctest Knockex

  test "greets the world" do
    assert Knockex.hello() == :world
  end
end
