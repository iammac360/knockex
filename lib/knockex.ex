defmodule Knockex do
  @moduledoc """
  Documentation for Knockex.
  """

  use Application
  alias Knockex.{VirusTotal, Wordlist}
  import Knockex.DomainResolver

  @timeout 5000

  def start(_type, _args) do
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def execute_optimus(version, argv) do
    Optimus.new!(
      name: "Knockex",
      description: "Knockex is an elixir tool based on `knockpy` to enumerate subdomain on a target domain",
      version: version,
      author: "Mark Sargento iammac.dicoder@gmail.com",
      about: "Utility for enumerating subdomain of a target domain",
      allow_unknown_args: false,
      parse_double_dash: true,
      args: [
        domain: [
          value_name: "DOMAIN",
          help: "Target domain to scan. For e.g. images.google.com, uber.com",
          required: true,
          parser: :string
        ]
      ],
      options: [
        wordlist: [
          value_name: "WORDLIST",
          short: "-w",
          long: "--wordlist",
          help: "specific path to wordlist file",
          parser: fn(s) ->
            case Date.from_iso8601(s) do
              {:error, _} -> {:error, "invalid date"}
              {:ok, _} = ok -> ok
            end
          end,
          required: false
        ]
      ]
    ) |> Optimus.parse!(argv)
  end

  def print_header(version) do
    """

      ██╗  ██╗███╗   ██╗ ██████╗  ██████╗██╗  ██╗    ███████╗██╗  ██╗
      ██║ ██╔╝████╗  ██║██╔═══██╗██╔════╝██║ ██╔╝    ██╔════╝╚██╗██╔╝
      █████╔╝ ██╔██╗ ██║██║   ██║██║     █████╔╝     █████╗   ╚███╔╝ 
      ██╔═██╗ ██║╚██╗██║██║   ██║██║     ██╔═██╗     ██╔══╝   ██╔██╗ 
      ██║  ██╗██║ ╚████║╚██████╔╝╚██████╗██║  ██╗    ███████╗██╔╝ ██╗
      ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝
                                                          Ver. #{version}

    """
  end

  def main(argv) do
    version = "0.1.0"
    file = "./wordlist.txt"

    IO.puts(print_header(version))
    %{args: %{domain: domain}} = execute_optimus(version, argv)

    IO.puts "\n"
    IO.puts "+ Checking for subdomains"


    subdomains = VirusTotal.get_subdomains(domain) ++ Wordlist.get_subdomains(domain, file)

    IO.inspect(subdomains)

    data = subdomains 
    |> Enum.map(fn(target) -> Task.async(fn -> resolve(target) end) end) 
    |> Enum.map(fn(task) -> Task.await(task, @timeout) end)
    |> List.flatten 
    |> Enum.filter(fn(d) -> d != nil end)

    Scribe.print(data, style: Scribe.Style.GithubMarkdown)

    IO.puts "TOTAL SUBDOMAINS: #{length(data)}"
  end
end
