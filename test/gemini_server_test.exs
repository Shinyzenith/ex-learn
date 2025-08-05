defmodule GeminiServerTest do
  use ExUnit.Case
  doctest GeminiServer

  test "greets the world" do
    assert GeminiServer.hello() == :world
  end
end
