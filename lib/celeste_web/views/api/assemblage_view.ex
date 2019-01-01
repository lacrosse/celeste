defmodule CelesteWeb.API.AssemblageView do
  alias Celeste.Content.File, as: CFile

  def render("index.json", %{assemblages: assemblages}) do
    %{
      assemblages: assemblages |> Enum.map(&render_partial(&1, %{}))
    }
  end

  def render("short_show.json", %{assemblage: assemblage}) do
    %{assemblage: render_partial(assemblage, %{})}
  end

  def render("show.json", %{assemblage: assemblage, user: user}) do
    assemblage =
      assemblage
      |> Celeste.Repo.preload(:files)
      |> Celeste.Repo.preload(:tags)
      |> Celeste.Repo.preload(:child_assemblies)
      |> Celeste.Repo.preload(:parent_assemblies)
      |> Celeste.Repo.preload(parent_assemblages: :tags)
      |> Celeste.Repo.preload(child_assemblages: :tags)

    root =
      %{}
      |> attach_assemblages(assemblage.parent_assemblages)
      |> attach_assemblages(assemblage.child_assemblages)
      |> attach_assemblies(assemblage.parent_assemblies)
      |> attach_assemblies(assemblage.child_assemblies)

    {render_partial(assemblage, %{}), root}
    |> embed(assemblage.tags, %{root: :tags, as: :tag_ids})
    |> embed(assemblage.files, %{root: :files, as: :file_ids, with: %{user: user}})
    |> finalize()
  end

  defp attach_assemblages(root, assemblages) do
    assemblages
    |> Enum.map_reduce(root, fn assemblage, root ->
      {render_partial(assemblage, %{}), root}
      |> embed(assemblage.tags, %{root: :tags, as: :tag_ids})
    end)
    |> put_in_root(:assemblages)
  end

  defp attach_assemblies(root, assemblies) do
    assemblies
    |> Enum.map_reduce(root, fn assembly, root ->
      {render_partial(assembly, %{}), root}
    end)
    |> put_in_root(:assemblies)
  end

  defp finalize({response, root}), do: Map.merge(root, %{assemblage: response})

  defp embed({response, root}, relationship, opts) do
    ids = Enum.map(relationship, & &1.id)
    entities = Enum.map(relationship, &render_partial(&1, opts[:with]))

    {Map.merge(response, %{opts[:as] => ids}), deep_merge(root, %{opts[:root] => entities})}
  end

  defp put_in_root({list, root}, key), do: deep_merge(root, %{key => list})

  defp deep_merge(map1, map2) do
    Map.merge(map1, map2, fn _, v1, v2 -> v1 ++ v2 end)
  end

  defp render_partial(%Celeste.KB.Assemblage{} = assemblage, _) do
    %{
      id: assemblage.id,
      name: assemblage.name,
      kind: assemblage.kind
    }
  end

  defp render_partial(%CFile{id: id, mime: mime, path: path} = file, %{user: user}) do
    %{
      id: id,
      path: CFile.jwt(file, user),
      mime: mime,
      name: Path.basename(path)
    }
  end

  defp render_partial(%Celeste.Assembly{} = assembly, _) do
    %{
      assemblage_id: assembly.assemblage_id,
      child_assemblage_id: assembly.child_assemblage_id,
      kind: assembly.kind
    }
  end

  defp render_partial(%Celeste.KB.Tag{} = tag, _) do
    %{
      id: tag.id,
      key: tag.key,
      value: tag.value
    }
  end
end
