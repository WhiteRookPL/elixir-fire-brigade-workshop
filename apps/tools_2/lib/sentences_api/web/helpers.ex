defmodule SentencesAPI.Web.Helpers do
  def get_random_from(list) do
    :rand.seed(:exs1024, :os.timestamp())
    {:ok, element} = Enum.fetch(list, Kernel.trunc(:rand.uniform() * length(list)))

    element
  end
end