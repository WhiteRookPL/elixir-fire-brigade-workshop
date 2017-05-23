defmodule SpellCheckerAPI.Web.DictionaryController do
  use SpellCheckerAPI.Web, :controller

  def words_for_letter(conn, params) do
    letter = String.downcase(String.first(params["letter"]))
    render conn, "words.json", letter: letter, words: SpellCheckerAPI.Web.DictionaryProvider.words_for_letter(letter)
  end
end