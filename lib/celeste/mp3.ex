defmodule Celeste.MP3 do
  use Bitwise

  @header_size 10
  @stream_chunk 10240
  @id3v2_data %{id_bytes: [], version_bytes: [], flags_byte: nil, frames_size_bytes: []}

  def id3v2(path) do
    data = path |> path_to_data()

    frames =
      data.frames_bytes
      |> :binary.list_to_bin()
      |> frames_binary_to_frames_list()
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))

    data
    |> Map.delete(:frames_bytes)
    |> Map.put(:frames, frames)
  end

  defp path_to_data(path) do
    path
    |> File.stream!([], @stream_chunk)
    |> Stream.flat_map(&:binary.bin_to_list/1)
    |> Stream.transform({0, @id3v2_data}, fn byte, acc ->
      case acc do
        {idx, data} when idx in (0..2) ->
          # Read header
          {[], {idx + 1, %{data | id_bytes: data.id_bytes ++ [byte]}}}
        {idx, data} when idx in (3..4) ->
          {[], {idx + 1, %{data | version_bytes: data.version_bytes ++ [byte]}}}
        {idx, data} when idx == 5 ->
          {[], {idx + 1, %{data | flags_byte: byte}}}
        {idx, data} when idx in (6..9) ->
          {[], {idx + 1, %{data | frames_size_bytes: data.frames_size_bytes ++ [byte]}}}
        {idx, %{id_bytes: id, version_bytes: version, flags_byte: flags, frames_size_bytes: frames_size} = data} ->
          # Process header
          'ID3' = id
          [major_version, revision] = version
          data =
            data
            |> Map.delete(:id_bytes)
            |> Map.delete(:version_bytes)
            |> Map.delete(:flags_byte)
            |> Map.delete(:frames_size_bytes)
            |> Map.merge(%{
              version: {major_version, revision},
              flags: %{
                unsynchronization: (flags &&& 0b10000000) != 0,
                extended_header: (flags &&& 0b01000000) != 0,
                experimental: (flags &&& 0b00100000) != 0
              },
              frames_size: unpacked_size(frames_size),
              reversed_frames_bytes: [byte]
            })

          {[], {idx + 1, data}}
        {idx, %{frames_size: n, reversed_frames_bytes: bytes} = data} when idx < @header_size + n ->
          {[], {idx + 1, %{data | reversed_frames_bytes: [byte|bytes]}}}
        {_, data} ->
          {reversed, data} =
            data
            |> Map.delete(:frames_size)
            |> Map.pop(:reversed_frames_bytes)

          data =
            data
            |> Map.put(:frames_bytes, reversed |> Enum.reverse)

          {[data], nil}
        nil -> {:halt, nil}
      end
    end)
    |> Enum.at(0)
  end

  defp frames_binary_to_frames_list(binary, acc \\ [])
  defp frames_binary_to_frames_list("", acc), do: acc
  defp frames_binary_to_frames_list(<<0, _::binary>>, acc), do: acc
  defp frames_binary_to_frames_list(binary, acc) do
    <<header::binary-size(10), binary::binary>> = binary
    <<id::binary-size(4), size::binary-size(4), flags::binary-size(2)>> = header
    <<frame_size::integer-32>> = size
    <<raw_encoded_frame::binary-size(frame_size), binary::binary>> = binary
    <<encoding::integer-8, frame_remainder::binary>> = raw_encoded_frame

    frame =
      case encoding do
        0 -> frame_remainder
        1 -> frame_remainder |> utf16_to_string()
        _ -> raw_encoded_frame
      end
      |> strip_zero_padding()

    tuple = {id, frame}

    frames_binary_to_frames_list(binary, [tuple | acc])
  end

  defp utf16_to_string(<<bom::binary-size(2), binary::binary>>) do
    {encoding, _} = :unicode.bom_to_encoding(bom)
    binary |> :unicode.characters_to_binary(encoding)
  end

  defp strip_zero_padding(binary, acc \\ <<>>)
  defp strip_zero_padding(<<>>, acc), do: acc
  defp strip_zero_padding(<<0>>, acc), do: acc
  defp strip_zero_padding(<<c, binary::binary>>, acc), do: strip_zero_padding(binary, acc <> <<c>>)

  defp unpacked_size(list) do
    Enum.reduce(list, 0, & (&2 <<< 7) + &1)
  end
end
