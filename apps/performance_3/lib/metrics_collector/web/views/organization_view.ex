defmodule MetricsCollector.Web.OrganizationView do
  use MetricsCollector.Web, :view

  def render("single.json", %{ organization: organization }) do
    %{
      id: organization.id,
      name: organization.name,
      created_at: organization.inserted_at,
      updated_at: organization.updated_at
    }
  end

  def render("list.json", %{ organizations: organizations }) do
    Enum.map(organizations, fn(org) -> render("single.json", %{ organization: org }) end)
  end
end