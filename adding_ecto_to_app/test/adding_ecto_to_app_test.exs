defmodule AddingEctoToAppTest do
  use ExUnit.Case
  doctest AddingEctoToApp

  test "greets the world" do
    assert AddingEctoToApp.hello() == :world
  end
end
