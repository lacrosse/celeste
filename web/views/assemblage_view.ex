defmodule Zongora.AssemblageView do
  use Zongora.Web, :view

  def wikipedia_path(topic) do
    "https://en.wikipedia.org/wiki/#{String.replace(topic, " ", "_")}"
  end

  def composers_list(conn, composers) do
    composers
    |> Enum.map(&link(&1.name, to: assemblage_path(conn, :show, &1.id)))
    |> Enum.intersperse(", ")
  end
end
