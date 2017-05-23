defmodule SpellCheckerAPI.Web.Router do
  use SpellCheckerAPI.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SpellCheckerAPI.Web do
    pipe_through :api

    get "/spell-check/:word", CheckerController, :spell_check
    get "/dictionary/:letter", DictionaryController, :words_for_letter
  end
end
