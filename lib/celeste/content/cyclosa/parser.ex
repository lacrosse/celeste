defmodule Celeste.Content.Cyclosa.Parser do
  import Ecto.Query, only: [from: 2]

  alias Celeste.Repo
  alias Celeste.KB.Assemblage

  @artist_name_regex "\\b[\\s\\w]+\\b"
  @instrument_regex "\\b\w+\\b"
  @operable_regex "(?:#{@instrument_regex}|#{@artist_name_regex})"
  @artist_group_regex "((?:#{@artist_name_regex}, )*#{@artist_name_regex}) {(#{@operable_regex})}"
  @artist_groups_regex "(?:#{@artist_group_regex} )*#{@artist_group_regex}"
  @ensemble_regex "(#{@artist_name_regex}) \\[(#{@artist_groups_regex})\\]"
  @nested_artist_group_regex "#{@ensemble_regex}|#{@artist_group_regex}"

  def parse_recordings do
    from(a in Assemblage, where: a.kind == "recording")
    |> Repo.all()
    |> Stream.map(&parse_recording/1)
  end

  # TODO refactor
  def parse_composition(%Assemblage{name: name}) do
    with regex = ~r/\s*\[(?<creation_date>.+)\]\s*/,
         creation_date = Regex.named_captures(regex, name)["creation_date"],
         filtered_name = Regex.replace(regex, name, ""),
         do: %{
           name: filtered_name,
           creation_date: creation_date
         }
  end

  defp parse_recording(%Assemblage{name: string}) do
    [dating, positioning, artists_string] =
      Regex.run(~r/\A(?:([\d,\.\-]+) )?(?:\[(.+)\] )?(.+)\z/, string, capture: :all_but_first)

    artists = parse_artists(artists_string)

    %{full: string, dating: dating, positioning: positioning, artists: artists}
  end

  defp parse_artists(string) do
    Regex.scan(~r/#{@nested_artist_group_regex}/, string)
    |> Enum.map(fn [nested_artist_group | _] ->
      case Regex.run(~r/\A#{@ensemble_regex}\z/, nested_artist_group, capture: :all_but_first) do
        nil ->
          parse_artist_group(nested_artist_group)

        [ensemble_name, artist_groups_strings | _] ->
          %{
            type: :ensemble,
            name: ensemble_name,
            artist_groups: parse_artists(artist_groups_strings)
          }
      end
    end)
  end

  defp parse_artist_group(string) do
    case Regex.run(~r/\A#{@artist_group_regex}\z/, string, capture: :all_but_first) do
      [artist_names_string, operable] ->
        artist_names =
          Regex.scan(~r/#{@artist_name_regex}/, artist_names_string) |> Enum.flat_map(& &1)

        %{type: :artist_group, artist_names: artist_names, operable: operable}
    end
  end
end
