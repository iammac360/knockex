defmodule Knockex.VirusTotal do
  import Knockex.Error

  def get_subdomains(domain) do
    api_host = "https://www.virustotal.com/vtapi/v2/domain/report"
    apikey = Application.get_env(:knockex, :virus_total_key)

    case HTTPotion.get(api_host, query: %{apikey: apikey, domain: domain}) do
      %HTTPotion.Response{body: body, status_code: 200} ->
        decode_response(body)
      _ -> handle_error("ERROR: Problem fetching subdomains on virustotal")
    end
  end

  defp decode_response(body) do
    case Poison.decode!(body) do
      %{"subdomains" => subdomains} -> subdomains
      %{"verbose_msg" => verbose_msg} -> handle_error(verbose_msg)
    end
  end
end
