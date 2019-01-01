defmodule Cyclosa.Parser do
  alias Celeste.KB.Assemblage

  def parse_composition(%Assemblage{} = composition) do
    with regex = ~r|\s*\[(?<creation_date>.+)\]\s*|,
         creation_date = Regex.named_captures(regex, composition.name)["creation_date"],
         filtered_name = Regex.replace(regex, composition.name, ""),
         do: %{
           name: filtered_name,
           creation_date: creation_date
         }
  end
end
