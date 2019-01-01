defmodule Celeste.MP3.ID3v2p4 do
  use Bitwise

  @header_size 10

  def read_streamed_byte(byte, {5, data}) do
    flags = decode_header_flags(<<byte>>)
    data = Map.put(data, :flags, flags)

    case flags do
      %{extended_header: 1} ->
        {:halt, Map.put(data, :error, "extended header is more than I can handle")}

      _ ->
        {:cont, {6, data}}
    end
  end

  def read_streamed_byte(byte, {idx, data}) when idx in 6..8 do
    {:cont, {idx + 1, Map.update(data, :frames_size_bytes, [byte], &(&1 ++ [byte]))}}
  end

  def read_streamed_byte(byte, {9, data}) do
    {frames_size_bytes, data} = Map.pop(data, :frames_size_bytes)
    {:cont, {10, Map.put(data, :frames_size, unpack_7bit_list(frames_size_bytes ++ [byte]))}}
  end

  def read_streamed_byte(byte, {idx, %{frames_size: n} = data}) when idx < @header_size + n - 1 do
    {:cont, {idx + 1, Map.update(data, :reversed_frames_bytes, [byte], &[byte | &1])}}
  end

  def read_streamed_byte(_, {idx, %{frames_size: n} = data}) when idx == @header_size + n - 1 do
    {reversed, data} =
      data
      |> Map.delete(:frames_size)
      |> Map.pop(:reversed_frames_bytes)

    {:halt, Map.put(data, :frames_binary, reversed |> Enum.reverse() |> :binary.list_to_bin())}
  end

  def decode_frames(binary, acc \\ [])
  def decode_frames("", acc), do: acc
  def decode_frames(<<0>> <> _, acc), do: acc

  def decode_frames(binary, acc) do
    <<header::binary-10, binary::binary>> = binary
    <<id::binary-4, size_bytes::binary-4, flag_bytes::binary-2>> = header

    frame_size = size_bytes |> :binary.bin_to_list() |> unpack_7bit_list()
    flags = flag_bytes |> decode_frame_flags()

    <<encoded_frame::binary-size(frame_size), binary::binary>> = binary

    {data_length, encoded_frame} =
      if flags.data_length_indicator == 1 do
        <<data_length::integer-32, rem::binary>> = encoded_frame
        {data_length, rem}
      else
        {nil, encoded_frame}
      end

    encoded_frame =
      if flags.unsynchronization == 1,
        do: encoded_frame |> undo_unsynchronization!(),
        else: encoded_frame

    <<encoding::integer-8, frame_remainder::binary>> = encoded_frame

    frame =
      case encoding do
        0 ->
          frame_remainder |> verify_length_or_unterminate!(data_length, <<0>>)

        1 ->
          frame_remainder
          |> verify_length_or_unterminate!(data_length, <<0, 0>>)
          |> decode_utf16()

        2 ->
          frame_remainder
          |> verify_length_or_unterminate!(data_length, <<0, 0>>)
          |> decode_utf16be()

        3 ->
          frame_remainder |> verify_length_or_unterminate!(data_length, <<0>>)

        _ ->
          raise("unknown frame encoding")
      end

    tuple = {id, frame}

    decode_frames(binary, [tuple | acc])
  end

  defp decode_utf16(<<bom::binary-2, binary::binary>>) do
    {encoding, _} = :unicode.bom_to_encoding(bom)
    binary |> :unicode.characters_to_binary(encoding)
  end

  defp decode_utf16be(binary), do: binary |> :unicode.characters_to_binary({:utf16, :big})

  defp decode_header_flags(binary) do
    <<unsync::size(1), ext::size(1), experimental::size(1), footer::size(1), _::bits>> = binary

    %{
      unsynchronization: unsync,
      extended_header: ext,
      experimental: experimental,
      footer: footer
    }
  end

  defp decode_frame_flags(binary) do
    <<0::size(1), tag_preservation::size(1), file_preservation::size(1), read_only::size(1),
      0::size(1), 0::size(1), 0::size(1), 0::size(1), 0::size(1), grouping::size(1), 0::size(1),
      0::size(1), compression::size(1), encryption::size(1), unsync::size(1),
      data_length_indicator::size(1)>> = binary

    %{
      tag_preservation: tag_preservation,
      file_preservation: file_preservation,
      read_only: read_only,
      grouping: grouping,
      compression: compression,
      encryption: encryption,
      unsynchronization: unsync,
      data_length_indicator: data_length_indicator
    }
  end

  defp undo_unsynchronization!(binary, acc \\ <<>>)
  defp undo_unsynchronization!(<<>>, acc), do: acc

  defp undo_unsynchronization!(<<255, 0, 0b111::size(3), rem::size(5), tail::binary>>, acc) do
    undo_unsynchronization!(tail, acc <> <<255, 0b111::size(3), rem::size(5)>>)
  end

  defp undo_unsynchronization!(<<c>> <> binary, acc),
    do: undo_unsynchronization!(binary, acc <> <<c>>)

  defp verify_length_or_unterminate!(binary, n, _) when is_integer(n) do
    if String.length(binary) + 1 == n,
      do: binary,
      else: raise("incorrect length")
  end

  defp verify_length_or_unterminate!(binary, _, terminator), do: unterminate!(binary, terminator)

  defp unterminate!(binary, terminator, acc \\ <<>>)
  defp unterminate!(<<>>, _, _), do: raise("terminator missing")
  defp unterminate!(terminator, terminator, acc), do: acc

  defp unterminate!(<<c>> <> binary, terminator, acc),
    do: unterminate!(binary, terminator, acc <> <<c>>)

  defp unpack_7bit_list(list) do
    Enum.reduce(list, 0, &((&2 <<< 7) + &1))
  end
end
