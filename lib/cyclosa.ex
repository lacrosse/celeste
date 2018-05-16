defmodule Cyclosa do
  require Ecto.Query

  alias Celeste.File, as: CFile
  alias Celeste.{Assemblage, Repo}

  @kbytes 10
  @mimes MapSet.new(~w|
    audio/mpeg
    audio/x-flac
  |)

  def crawl_dir(dir) do
    read_dir_recursively(dir)
  end

  defp read_dir_recursively(dir, parent \\ nil) do
    with grouped_read = read_dir(dir) |> Enum.group_by(fn {_, %{fstype: fstype}} -> fstype end) do
      dirs = Map.get(grouped_read, :directory, [])
      grouped_files = Map.get(grouped_read, :regular, [])

      {:ok, assemblage} =
        Repo.transaction fn ->
          case Repo.one(Ecto.Query.from a in Assemblage, where: a.name == ^dir, limit: 1) do
            nil ->
              %Assemblage{}
              |> Assemblage.create_changeset(%{name: dir})
              |> Repo.insert!()
            value -> value
          end
        end

      assemblage =
        assemblage
        |> Repo.preload(:parent_assemblages)
        |> Repo.preload(:files)

      if parent do
        assemblage
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:parent_assemblages, [parent])
        |> Repo.update!
      end

      files =
        grouped_files
        |> Enum.map(fn
          {path, attrs} -> {path, Map.merge(attrs, %{mime: MIME.from_path(path)})}
        end)
        |> select_interesting_files()
        |> Enum.map(fn
          {path, %{fstype: :regular} = attrs} ->
            {path, Map.merge(attrs, %{sha256: file_sha256(path)})}
          tuple ->
            tuple
        end)
        |> Enum.map(fn
          {path, %{mime: mime, size: size, sha256: sha256, atime: atime, ctime: ctime, mtime: mtime}} ->
            {:ok, result} =
              Repo.transaction fn ->
                case Repo.one(Ecto.Query.from f in CFile, where: f.sha256 == ^sha256, limit: 1) do
                  nil -> %CFile{}
                  value -> value
                end
                |> CFile.changeset(%{
                  path: path,
                  mime: mime,
                  size: size,
                  sha256: sha256,
                  seen_at: NaiveDateTime.utc_now(),
                  atime: atime,
                  ctime: ctime,
                  mtime: mtime
                })
                |> Repo.insert_or_update!
              end
            result
        end)

      if files |> Enum.count > 0 do
        assemblage
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:files, files ++ assemblage.files)
        |> Repo.update!
      end

      deeper_files =
        dirs
        |> Stream.flat_map(fn {path, _} -> read_dir_recursively(path, assemblage) end)

      files
      |> Stream.concat(deeper_files)
    end
  end

  defp read_dir(dir) do
    {:ok, paths} = File.ls(dir)

    paths
    |> Enum.map(&Path.join(dir, &1))
    |> Enum.map(fn path ->
      stat =
        case File.stat(path) do
          {:ok, value} -> value
          {:error, error} ->
            raise "Error! #{path} #{error}"
        end

      {path, %{
        fstype: stat.type,
        size: stat.size,
        atime: NaiveDateTime.from_erl!(stat.atime),
        ctime: NaiveDateTime.from_erl!(stat.ctime),
        mtime: NaiveDateTime.from_erl!(stat.mtime)
      }}
    end)
  end

  defp file_sha256(path) do
    File.stream!(path, [], @kbytes * 1024)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final
  end

  defp select_interesting_files(files) do
    files
    |> Enum.filter(fn {path, %{mime: mime}} ->
      Path.basename(path) != ".DS_Store" && #&& MapSet.member?(@mimes, mime)
      !Repo.one(Ecto.Query.from f in CFile, where: f.path == ^path, limit: 1)
    end)
  end
end
