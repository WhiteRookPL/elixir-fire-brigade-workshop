defmodule MetricsCollector.Web.Router do
  use MetricsCollector.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MetricsCollector.Web do
    pipe_through :api

    get "/organizations", OrganizationController, :list_all
    get "/organization/:id", OrganizationController, :get_by_id
    put "/organizations", OrganizationController, :create

    get "/pages", PageController, :list_all
    get "/page/:id", PageController, :get_by_id
    put "/pages", PageController, :create

    get "/tracking", TrackingPointController, :list_all
    get "/tracking/point/:id", TrackingPointController, :get_by_id
    get "/tracking/for_page/:page_id", TrackingPointController, :get_by_page_id
    put "/track", TrackingPointController, :create
  end
end
