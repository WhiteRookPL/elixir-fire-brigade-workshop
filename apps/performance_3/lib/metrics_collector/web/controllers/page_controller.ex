defmodule MetricsCollector.Web.PageController do
  use MetricsCollector.Web, :controller

  alias MetricsCollector.Schema.Repo
  alias MetricsCollector.Schema.Page
  alias MetricsCollector.Schema.Organization

  def list_all(conn, _params) do
    pages = Repo.all(Page)
    render conn, "list.json", pages: pages
  end

  def get_by_id(conn, %{ "id" => id }) do
    page = Repo.get!(Page, id)
    render conn, "single.json", page: page
  end

  def create(conn, %{ "page" => %{ "organization_id" => organization_id, "url" => url } }) do
    organization = Repo.get(Organization, organization_id)
    page = Repo.insert!(%Page{ url: url, organization: organization })
    render conn, "single.json", page: page
  end
end