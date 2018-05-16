defmodule Celeste.Parser do
  import Ecto.Query, only: [from: 2]

  alias Celeste.{Repo, Assemblage}

  def parse do
    year = "\\d{4}"
    date_extension = "(?:-\\d{2})?"
    extended_year = "(?:#{year}#{date_extension})"
    day = month = "\\.\\d{2}"
    extended_day = extended_month = "(?:#{month}#{date_extension})"
    flexible_subyear_boundary = "(#{month}#{extended_day}|#{extended_month})"
    optional_flexible_subyear_range = "#{flexible_subyear_boundary}(?:-#{flexible_subyear_boundary})?"
    date = "(#{year}#{optional_flexible_subyear_range}|#{extended_year})"
    location = "[^\\]]+"
    ensemble = ".+"
    solo_artist = ".+"
    artist = "(#{ensemble}|#{solo_artist})"

    optional_date = "(?:(?<date>#{date})\\. )?"
    optional_location = "(?:\\[(?<location>#{location})\\] )?"
    artists = "(?<artist>#{artist})+"

    regex = ~r/^#{optional_date}#{optional_location}#{artists}$/

    from(a in Assemblage,
      where: a.kind == "recording",
      where: a.id == 7407,
      select: a.name
    )
    |> Repo.all
    |> Stream.map(&{&1, Regex.named_captures(regex, &1)})
    |> Enum.take(10)
  end
end
