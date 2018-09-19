defmodule Knockex.Error do
  def handle_error(message) do
    IO.puts message
    System.halt(0)
  end
end
