defmodule MetricsCollector.Web.OrganizationController do
  use MetricsCollector.Web, :controller

  alias MetricsCollector.Schema.Repo
  alias MetricsCollector.Schema.Organization

  def list_all(conn, _params) do
    organizations = Repo.all(Organization)
    render conn, "list.json", organizations: organizations
  end

  def get_by_id(conn, %{ "id" => id }) do
    organization = Repo.get!(Organization, id)
    render conn, "single.json", organization: organization
  end

  def create(conn, %{ "organization" => %{ "name" => name } }) do
    organization = Repo.insert!(%Organization{ name: name })
    render conn, "single.json", organization: organization
  end
end