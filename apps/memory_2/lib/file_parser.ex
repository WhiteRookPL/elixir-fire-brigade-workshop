defmodule Audiophile.FileParser do
  @default_port_timeout 5_000

  def extract_tags_from_mp3(filename) do
    case File.read(filename) do
      {:ok, mp3} ->
        try do
          mp3_byte_size = byte_size(mp3) - 128

          << _ :: binary-size(mp3_byte_size), id3_tag :: binary >> = mp3
          << _tag      :: binary-size(3),
             _title    :: binary-size(30),
             artist    :: binary-size(30),
             _album    :: binary-size(30),
             _year     :: binary-size(4),
             _comment  :: binary-size(28),
             _reserved :: binary-size(1),
             _track    :: binary-size(1),
             _genre    :: binary-size(1) >> = id3_tag

          {:ok, %{ artist: pretty_print(artist), id3: id3_tag }}
        catch
          _ -> {:error, {filename, :invalid_id3_tag}}
        end

      _ ->
        {:error, {filename, :cannot_open_file}}
    end
  end

  def extract_duration(filename) do
    port = Port.open({:spawn, "mp3info -p \"%S\" \"#{filename}\""}, [:binary, :stderr_to_stdout])

    receive do
      {^port, {:data, seconds}} ->
        Port.close(port)

        receive do
          {^port, :closed} ->
            case Integer.parse(seconds) do
              {seconds, _} -> {:ok, seconds}
              :error       -> {:error, :duration_not_available}
            end
        after
          @default_port_timeout -> {:error, :port_not_responding}
        end
    after
      @default_port_timeout ->
        Port.close(port)

        receive do
          {^port, :closed} -> {:error, :port_not_responding}
        after
          @default_port_timeout -> {:error, :port_not_responding}
        end
    end
  end

  defp pretty_print(raw) do
    String.codepoints(raw)
    |> Enum.filter(&String.valid?/1)
    |> Enum.filter(fn(codepoint) -> codepoint != <<0>> end)
    |> Enum.join("")
    |> String.trim()
  end
end