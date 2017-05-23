defmodule SentencesAPI.Web.Helpers do
  def get_random_from(list) do
    {:ok, element} = Enum.fetch(list, Kernel.trunc(:random.uniform() * length(list)))
    element
  end
end