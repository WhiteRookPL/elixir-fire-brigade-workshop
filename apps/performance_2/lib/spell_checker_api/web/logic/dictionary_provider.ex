defmodule SpellCheckerAPI.Web.DictionaryProvider do
  def words_for_letter(letter) do
    [ {:words, content} ] = :ets.lookup(SpellCheckerAPI.Cache, :words)

    content
    |> Enum.filter(fn(line) -> String.first(line) == letter end)
    |> Enum.map(&String.downcase/1)
    |> Enum.map(fn(line) -> String.split(line, " ") end)
    |> List.flatten()
  end

  def valid?(word) do
    words_for_letter(String.first(word))
    |> Enum.member?(word)
  end
end