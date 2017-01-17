defmodule Celeste.MP3 do
  @stream_chunk 10240

  def id3(path) do
    data =
      path
      |> to_bytestream()
      |> reduce_bytestream_to_id3()

    if Map.has_key?(data, :error),
    do: {:error, data},
    else: {:ok, data}
  end

  defp to_bytestream(path) do
    path
    |> File.stream!([], @stream_chunk)
    |> Stream.flat_map(&:binary.bin_to_list/1)
  end

  defp reduce_bytestream_to_id3(stream) do
    data =
      stream
      |> Enum.reduce_while({0, %{}}, fn
        byte, {idx, data} when idx in (0..1) ->
          {:cont, {idx + 1, Map.update(data, :id_bytes, [byte], & &1 ++ [byte])}}
        byte, {2, data} ->
          {id_bytes, data} = Map.pop(data, :id_bytes)
          case id_bytes ++ [byte] do
            'ID3' ->
              {:cont, {3, data}}
            _ ->
              {:halt, Map.put(data, :error, "no ID3v2 tag detected")}
          end
        byte, {3, data} ->
          {:cont, {4, Map.update(data, :version_bytes, [byte], & &1 ++ [byte])}}
        byte, {4, data} ->
          {version_bytes, data} = Map.pop(data, :version_bytes)
          [major_version, revision] = version_bytes ++ [byte]
          {:cont, {5, Map.put(data, :version, {major_version, revision})}}
        byte, {idx, %{version: {3, _}}} = acc when idx >= 5 ->
          Celeste.MP3.ID3v2p3.read_streamed_byte(byte, acc)
        byte, {idx, %{version: {4, _}}} = acc when idx >= 5 ->
          Celeste.MP3.ID3v2p4.read_streamed_byte(byte, acc)
      end)

    {data, frames} =
      case data.version do
        {3, _} ->
          {binary, data} = Map.pop(data, :frames_binary)
          frames = Celeste.MP3.ID3v2p3.decode_frames(binary)
          {data, frames}
        {4, _} ->
          {binary, data} = Map.pop(data, :frames_binary)
          frames = Celeste.MP3.ID3v2p4.decode_frames(binary)
          {data, frames}
      end

    frames =
      frames
      |> Enum.map(fn
        {key, {subkey, values}} when key in ["PRIV", "TXXX"] ->
          {"#{key}_#{subkey}", values}
        tuple ->
          tuple
      end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    Map.put(data, :frames, frames)
  end
end
