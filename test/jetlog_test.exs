defmodule JetlogTest do
  use ExUnit.Case
  doctest Jetlog

  test "greets the world" do
    assert Jetlog.hello() == :world
  end
end
