defmodule Celeste.AssemblageView do
  use Celeste.Web, :view

  alias Celeste.Assemblage
  alias Celeste.File, as: ZFile

  def wikipedia_path(topic) do
    "https://en.wikipedia.org/wiki/#{String.replace(topic, " ", "_")}"
  end

  def composers_list(conn, [_, _] = composers), do: do_composers_list(conn, composers, " and ")
  def composers_list(conn, composers), do: do_composers_list(conn, composers, ", ")

  defp enumerate_naturally([_, _] = collection, fun, arg), do: fun(arg, collection, " and ")
  defp enumerate_naturally(collection)

  defp do_composers_list(conn, composers, sep) do
    composers
    |> Enum.map(&assemblage_link(conn, &1))
    |> Enum.intersperse(sep)
  end

  def composition_row(conn, composition) do
    {high_priority_tags, low_priority_tags} = prioritize_tags(composition)
    [
      tags_row(high_priority_tags, "primary"),
      assemblage_link(conn, composition),
      tags_row(low_priority_tags)
    ]
    |> Enum.intersperse(" ")
  end

  def composed_by(conn, composition) do
    composers = Celeste.Assemblage.parent_assemblages_of_kind(composition, "composed") |> Celeste.Repo.all

    who = [
      "composed by ",
      composers_list(conn, composers)
    ]

    case tags_with_keys(composition, ~w|creation_date|) do
      [] ->
        who
      [date_tag] ->
        [who, " in ", date_tag.value]
    end
  end

  def prioritize_tags(%Assemblage{kind: "composition"} = assemblage) do
    groups =
      assemblage.tags
      |> Enum.group_by(& &1.key)

    {high, groups} =
      ~w|creation_date|
      |> Enum.reduce({[], groups}, fn x, {acc, groups} ->
        {popped, groups} = Map.pop(groups, x, [])
        {acc ++ popped, groups}
      end)

    low = groups |> Map.to_list |> Enum.flat_map(&elem(&1, 1))

    {high, low}
  end

  def prioritize_tags(%Assemblage{} = assemblage) do
    {[], assemblage.tags}
  end

  def tags_with_keys(assemblage, keys) do
    assemblage.tags |> Enum.filter(&Enum.member?(keys, &1.key))
  end

  def tags_without_keys(assemblage, keys) do
    assemblage.tags |> Enum.reject(&Enum.member?(keys, &1.key))
  end

  def full_assemblage_name(conn, a, opts \\ %{})
  def full_assemblage_name(conn, %Assemblage{kind: "composition"} = composition, opts) do
    name =
      cond do
        opts[:link] -> assemblage_link(conn, composition)
        true -> composition.name
      end
    case tags_with_keys(composition, ~w|tonality|) do
      [] -> [name]
      [tag] -> [name, " in #{tag.value}"]
    end
  end
  def full_assemblage_name(_, assemblage, _), do: assemblage.name

  def tags_row(tags, class \\ "info") do
    tags
    |> Enum.map(&tag_label(&1, class))
    |> Enum.intersperse(" ")
  end

  def tag_label(tag, class) do
    content_tag :span, tag.value, class: "label label-#{class}"
  end

  defp assemblage_link(conn, assemblage) do
    link(assemblage.name, to: assemblage_path(conn, :show, assemblage.id))
  end

  def file_link(conn, file) do
    link Path.basename(file.path), to: file_path(conn, :show, ZFile.link_param(file))
  end
end
