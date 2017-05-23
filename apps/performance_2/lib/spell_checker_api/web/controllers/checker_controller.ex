defmodule SpellCheckerAPI.Web.CheckerController do
  use SpellCheckerAPI.Web, :controller

  def spell_check(conn, params) do
    word = String.downcase(params["word"])
    render conn, "spell_checker.json", word: word, valid: SpellCheckerAPI.Web.DictionaryProvider.valid?(word)
  end
end