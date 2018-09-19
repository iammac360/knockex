defmodule Knockex.Wordlist do
  import Knockex.Error

  def get_subdomains(domain, file) do
    case File.read(file) do
      {:ok, text} -> 
        String.split(text, "\n")
        |> Enum.map(fn(t) -> "#{t}.#{domain}" end)
      {:error, :enoent} -> handle_error("Wordlist file not found")
    end
  end
end
