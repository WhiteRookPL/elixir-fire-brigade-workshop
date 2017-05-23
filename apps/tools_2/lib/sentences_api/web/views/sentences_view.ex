defmodule SentencesAPI.Web.SentencesView do
  use SentencesAPI.Web, :view

  def render("index.json", %{sentences: sentences}) do
    %{
      sentences: Enum.map(sentences, &sentence_json/1)
    }
  end

  def sentence_json(sentence) do
    %{
      text: sentence.text,
      author: sentence.author
    }
  end
end