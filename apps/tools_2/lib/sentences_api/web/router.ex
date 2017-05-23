defmodule SentencesAPI.Web.Router do
  use SentencesAPI.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SentencesAPI.Web do
    pipe_through :api

    get "/sentences", SentencesController, :all
    get "/sentences/random", SentencesController, :random
  end
end
