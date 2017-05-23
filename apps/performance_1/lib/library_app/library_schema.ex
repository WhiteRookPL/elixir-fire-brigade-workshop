defmodule LibraryApp.Schema do
  use Absinthe.Schema

  import_types LibraryApp.Schema.Types

  query do
    field :book, :book do
      arg :id, non_null(:id)

      resolve &LibraryApp.Resolver.single_book/2
    end

    field :book, :book do
      arg :id, non_null(:id)

      resolve &LibraryApp.Resolver.single_author/2
    end

    field :books, list_of(:book) do
      resolve &LibraryApp.Resolver.all_books/2
    end

    field :authors, list_of(:author) do
      resolve &LibraryApp.Resolver.all_authors/2
    end

    field :books_by_author, list_of(:book) do
      arg :author, non_null(:string)

      resolve &LibraryApp.Resolver.books_by_author/2
    end

    field :authors_by_title, list_of(:author) do
      arg :title, non_null(:string)

      resolve &LibraryApp.Resolver.authors_by_title/2
    end
  end

  mutation do
    field :create_book, :book do
      arg :title, non_null(:string)

      resolve &LibraryApp.Resolver.create_book/3
    end

    field :create_author, :author do
      arg :name, non_null(:string)
      arg :surname, non_null(:string)

      resolve &LibraryApp.Resolver.create_author/3
    end

    field :create_author_with_mixed_data, :author do
      arg :name_and_surname, non_null(:string)

      resolve &LibraryApp.Resolver.create_author/3
    end

    field :associate_book_with_author, :book do
      arg :title, non_null(:string)
      arg :author, non_null(:string)

      resolve &LibraryApp.Resolver.associate_book_with_author/3
    end
  end
end