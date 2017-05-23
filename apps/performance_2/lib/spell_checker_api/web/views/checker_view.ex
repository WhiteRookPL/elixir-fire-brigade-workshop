defmodule SpellCheckerAPI.Web.CheckerView do
  use SpellCheckerAPI.Web, :view

  def render("spell_checker.json", %{ word: word, valid: result}) do
    %{
      word: word,
      valid: result
    }
  end
end