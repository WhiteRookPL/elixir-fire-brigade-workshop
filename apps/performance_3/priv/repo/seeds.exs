defmodule Seed do
  alias MetricsCollector.Schema.Repo

  alias MetricsCollector.Schema.Organization
  alias MetricsCollector.Schema.Page
  alias MetricsCollector.Schema.TrackingPoint

  @user_agents [
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36",
    "Mozilla/4.0 (compatible; MSIE 9.0; Windows NT 6.1)",
    "Mozilla/5.0 (Linux; U; Android 2.2; en-gb; GT-P1000 Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
    "Opera/9.80 (J2ME/MIDP; Opera Mini/4.2/28.3492; U; en) Presto/2.8.119 Version/11.10",
    "Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101 Firefox/52.0",
    "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:44.0) Gecko/20100101 Firefox/44.0",
  ]

  def grow() do
    appliscale = Repo.insert!(Organization.changeset(%Organization{}, %{ name: "Appliscale" }))

    pages = for i <- 1 .. 100, into: [] do
      page_within_organization("https://appliscale.io/page_#{i}", appliscale)
    end

    for _ <- 1 .. 100_000 do
      json = Poison.decode!(File.read!(Path.expand("./priv/repo/payload.json")))
      Repo.insert!(point_for_page(json, Enum.random(pages)))
    end
  end

  defp page_within_organization(url, org) do
    %Page{ url: url, organization: org }
  end

  defp point_for_page(json, page) do
    %TrackingPoint{ user_agent: Enum.random(@user_agents), content: json, page: page }
  end
end

Seed.grow()