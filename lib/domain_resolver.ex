defmodule Knockex.DomainResolver do
  @timeout 5000

  def get_headers(hostname) do
    case HTTPotion.get(hostname, [timeout: @timeout]) do
      %{headers: %{hdrs: %{"server" => server}}, status_code: status_code} -> 
        {server, status_code}
      err -> 
        IO.inspect {"HEADER ERROR: #{hostname}", err}
        {"", ""}
    end
  end

  def resolve(target) do
    case :inet.gethostbyname(:erlang.binary_to_atom(target, :utf8)) do
      {:ok, {:hostent, hostname, alias_list, :inet, _len, addr_list}} ->
        {server, status_code} = get_headers(hostname)
        mold_data(server, status_code, hostname, alias_list, addr_list)
      err ->
        IO.inspect {"RESOLVE ERROR: #{target}", err}
        nil
    end
  end

  def mold_data(server, status_code, hostname, alias_list, addr_list) do
    Enum.map(alias_list, fn(alias_domain) ->
      IO.puts "Resolving #{alias_domain}"
      [ip | _] = addr_list
      ip_string = :inet_parse.ntoa(ip)
      %{ip: ip_string, hostname: alias_domain, type: "alias", server: server, status_code: status_code}
    end) ++ Enum.map(addr_list, fn(ip) -> 
      IO.puts "Resolving #{hostname}"
      ip_string = :inet_parse.ntoa(ip)
      %{ip: ip_string, hostname: hostname, type: "host", server: server, status_code: status_code}
    end)
  end
end
