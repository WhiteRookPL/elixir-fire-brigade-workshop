defmodule LibraryApp.Schema.Types do
  use Absinthe.Schema.Notation

  @desc "An author of the book"
  object :author do
    field :id, :id
    field :name, :string
    field :surname, :string
    field :books, list_of(:book)
  end

  @desc "A book created by one or multiple authors"
  object :book do
    field :id, :id
    field :title, :string
    field :authors, list_of(:author)
  end
end