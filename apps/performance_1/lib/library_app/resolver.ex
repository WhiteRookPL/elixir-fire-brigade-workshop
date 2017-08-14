defmodule LibraryApp.Resolver do
  def single_book(%{ :id => id }, _info) do
    title = File.read(priv("books/#{id}"))

    {:ok, %{ :id => id, :title => title }}
  end

  def single_author(%{ :id => id }, _info) do
    [name, surname] = String.split(File.read(priv("authors/#{id}")), ",")

    {:ok, %{ :id => id, :name => name, :surname => surname }}
  end

  def all_books(_arguments, info) do
    child_fields = Absinthe.Resolution.project(info) |> Enum.map(&(&1.name))

    books = get_books_lazily()

    final_books = case Enum.member?(child_fields, "authors") do
      true ->
        authors = get_authors_lazily()

        Enum.map(books, fn(%{ :id => book_id } = map) ->
          mapped_authors =
            Enum.filter(authors, fn(%{ :books => books_from_authors }) ->
              Enum.find(books_from_authors, fn(id) -> book_id == id end) != nil
            end)

          Map.put(map, :authors, mapped_authors)
        end)

      false ->
        books
    end

    {:ok, final_books}
  end

  def all_authors(_arguments, info) do
    child_fields = Absinthe.Resolution.project(info) |> Enum.map(&(&1.name))

    authors = get_authors_lazily()

    final_authors = case Enum.member?(child_fields, "books") do
      true ->
        books = get_books_lazily()

        Enum.map(authors, fn(%{ :books => book_ids } = map) ->
          mapped_books = Enum.map(book_ids, fn(id) ->
            Enum.find(books, fn(%{ :id => book_id }) -> book_id == id end)
          end)

          %{ map | books: mapped_books }
        end)

      false ->
        authors
    end

    {:ok, final_authors}
  end

  def books_by_author(%{ :author => author }, _info) do
    authors = get_authors_lazily()
    books = get_books_lazily()

    {author_name, author_surname} = separate_name_and_surname(author)
    author = Enum.find(authors, fn(%{ :name => name, :surname => surname }) -> name == author_name and surname == author_surname end)

    result = case author do
      %{ :books => book_ids } ->
        Enum.map(book_ids, fn(id) ->
          Enum.find(books, fn(%{ :id => book_id }) -> book_id == id end)
        end)

      nil ->
        []
    end

    {:ok, result}
  end

  def authors_by_title(%{ :title => book_title }, _info) do
    authors = get_authors_lazily()
    books = get_books_lazily()

    book = Enum.find(books, fn(%{ :title => title }) -> book_title == title end)

    result = case book do
      %{ :id => book_id } ->
        Enum.filter(authors, fn(%{ :books => book_ids }) ->
          Enum.member?(book_ids, book_id)
        end)

      nil ->
        []
    end

    {:ok, result}
  end

  def create_book(_arguments, %{ :title => title }, _info) do
    files = Path.wildcard(priv("books/*.book"))
    number = length(files) + 1

    File.write(priv("books/#{number}.book"), title)

    {:ok, %{ :id => number, :title => title }}
  end

  def create_author(_arguments, %{ :name => name, :surname => surname }, _info) do
    files = Path.wildcard(priv("authors/*.author"))
    number = length(files) + 1

    File.write(priv("authors/#{number}.author"), "#{name} #{surname}")

    {:ok, %{ :id => number, :name => name, :surname => surname }}
  end

  def create_author(_arguments, %{ :name_and_surname => name_and_surname }, _info) do
    {name, surname} = separate_name_and_surname(name_and_surname)

    files = Path.wildcard(priv("authors/*.author"))
    number = length(files) + 1

    File.write(priv("authors/#{number}.author"), "#{name} #{surname}")

    {:ok, %{ :id => number, :name => name, :surname => surname }}
  end

  def associate_book_with_author(_arguments, %{ :author => name_and_surname, :title => book_title }, _info) do
    {author_name, author_surname} = separate_name_and_surname(name_and_surname)

    author = Enum.find(get_authors_lazily(),  fn(%{ :name => name, :surname => surname }) -> name == author_name and surname == author_surname end)
    book = Enum.find(get_books_lazily(), fn(%{ :title => title }) -> book_title == title end)

    case {author, book} do
      {author, book} when author != nil and book != nil ->
        {:ok, content} = File.read(priv("authors/#{author[:id]}.author"))
        [name_and_surname | books] = String.split(content, "\n")

        updated_books = case books do
          []               -> "#{book[:id]}"
          [books_list | _] -> "#{books_list},#{book[:id]}"
        end

        File.write(priv("authors/#{author[:id]}.author"), "#{name_and_surname}\n#{updated_books}")

        {:ok, %{ author | :books => [ book ] }}

      _ ->
        {:error, :no_such_author_or_book}
    end
  end

  def get_books_lazily() do
    case :ets.lookup(LibraryApp.Cache, :books) do
      [ {_, content} ] -> content
      []               ->
        books = get_books()
        :ets.insert(LibraryApp.Cache, {:books, books})
        books
    end
  end

  def get_authors_lazily() do
    case :ets.lookup(LibraryApp.Cache, :authors) do
      [ {_, content} ] -> content
      []               ->
        authors = get_authors()
        :ets.insert(LibraryApp.Cache, {:authors, authors})
        authors
    end
  end

  defp get_authors() do
    Path.wildcard(priv("authors/*.author"))
    |> Enum.map(fn(file) -> {String.to_integer(only_number(file, "author")), File.read(file)} end)
    |> Enum.filter(fn({_, {atom, _}}) -> atom == :ok end)
    |> Enum.map(fn({id, {:ok, content}}) -> {id, String.split(content, "\n")} end)
    |> Enum.map(fn({id, [ surname_and_name | rest ]}) -> {id, String.trim(surname_and_name), handle_books(rest)} end)
    |> Enum.sort(fn({_, surname_and_name1, _}, {_, surname_and_name2, _}) -> surname_and_name1 <= surname_and_name2 end)
    |> Enum.map(fn({id, surname_and_name, book_ids}) -> {id, separate_name_and_surname(surname_and_name), Enum.map(book_ids, &String.to_integer/1)} end)
    |> Enum.map(fn({id, {name, surname}, book_ids}) -> %{ :id => id, :name => name, :surname => surname, :books => book_ids } end)
  end

  defp get_books() do
    Path.wildcard(priv("books/*.book"))
    |> Enum.map(fn(file) -> {String.to_integer(only_number(file, "book")), File.read(file)} end)
    |> Enum.filter(fn({_, {atom, _}}) -> atom == :ok end)
    |> Enum.map(fn({id, {:ok, title}}) -> {id, String.trim(title)} end)
    |> Enum.sort(fn({_, title1}, {_, title2}) -> title1 <= title2 end)
    |> Enum.map(fn({id, title}) -> %{ :id => id, :title => title } end)
  end

  defp handle_books([]), do: []
  defp handle_books([ book_ids | _ ]), do: String.split(book_ids, ",")

  defp only_number(file, ext) do
    Path.basename(Path.rootname(file, ".#{ext}"))
  end

  defp separate_name_and_surname(name_and_surname) do
    tokens = name_and_surname
             |> String.split(" ")

    surname = List.last(tokens)
    name = tokens
           |> Enum.reverse()
           |> Enum.drop(1)
           |> Enum.reverse()
           |> Enum.join(" ")

    {name, surname}
  end

  defp priv(subpath) do
    Path.join(:code.priv_dir(:library_app), subpath)
  end
end