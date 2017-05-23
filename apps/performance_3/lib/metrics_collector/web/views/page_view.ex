defmodule MetricsCollector.Web.PageView do
  use MetricsCollector.Web, :view

  def render("single.json", %{ page: page }) do
    %{
      id: page.id,
      url: page.url,
      organization_id: page.organization_id,
      created_at: page.inserted_at,
      updated_at: page.updated_at
    }
  end

  def render("list.json", %{ pages: pages }) do
    Enum.map(pages, fn(page) -> render("single.json", %{ page: page }) end)
  end
end