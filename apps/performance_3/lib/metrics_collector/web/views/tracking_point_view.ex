defmodule MetricsCollector.Web.TrackingPointView do
  use MetricsCollector.Web, :view

  def render("single.json", %{ tracking_point: tracking_point }) do
    %{
      id: tracking_point.id,
      page_id: tracking_point.page_id,
      user_agent: tracking_point.user_agent,
      content: tracking_point.content,
      created_at: tracking_point.inserted_at,
      updated_at: tracking_point.updated_at
    }
  end

  def render("list.json", %{ tracking_points: tracking_points }) do
    Enum.map(tracking_points, fn(tracking_point) -> render("single.json", %{ tracking_point: tracking_point }) end)
  end
end