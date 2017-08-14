defmodule MetricsCollector.Web.TrackingPointController do
  use MetricsCollector.Web, :controller

  import Ecto.Query, only: [ from: 2 ]

  alias MetricsCollector.Schema.Repo
  alias MetricsCollector.Schema.TrackingPoint
  alias MetricsCollector.Schema.Page

  def list_all(conn, %{ "limit" => limit }) do
    maximum = min(limit, 1000)
    query =
      from p in "tracking_points",
      limit: ^maximum,
      select: {p.id, p.user_agent, p.content, p.page_id, p.inserted_at, p.updated_at}

    tracking_points = Repo.all(query)
    render conn, "list.json", tracking_points: tracking_points
  end

  def get_by_id(conn, %{ "id" => id }) do
    tracking_point = Repo.get!(TrackingPoint, id)
    render conn, "single.json", tracking_point: tracking_point
  end

  def get_by_page_id(conn, %{ "page_id" => page_id }) do
    page = Repo.get!(Page, page_id) |> Repo.preload(:tracking_points)
    render conn, "list.json", tracking_points: page.tracking_points
  end

  def create(conn, %{ "tracking_point" => %{ "page_id" => page_id, "content" => content } }) do
    user_agent = case get_req_header(conn, "user-agent") do
      [ ua | _ ] -> ua
      []         -> "(no User-Agent header provided)"
    end

    page = Repo.get(Page, page_id)
    tracking_point = Repo.insert!(%TrackingPoint{ page: page, content: content, user_agent: user_agent })
    render conn, "single.json", tracking_point: tracking_point
  end
end