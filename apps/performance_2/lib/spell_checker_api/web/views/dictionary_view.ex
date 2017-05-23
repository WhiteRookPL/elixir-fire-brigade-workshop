defmodule SpellCheckerAPI.Web.DictionaryView do
  use SpellCheckerAPI.Web, :view

  def render("words.json", %{ letter: letter, words: words }) do
    %{
      letter: letter,
      words: words
    }
  end
end