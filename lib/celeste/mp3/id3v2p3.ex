defmodule Celeste.MP3.ID3v2p3 do
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
    {:cont, {idx + 1, Map.update(data, :frames_size_bytes, [byte], & &1 ++ [byte])}}
  end
  def read_streamed_byte(byte, {9, data}) do
    {frames_size_bytes, data} = Map.pop(data, :frames_size_bytes)
    {:cont, {10, Map.put(data, :frames_size, unpack_7bit_list(frames_size_bytes ++ [byte]))}}
  end
  def read_streamed_byte(byte, {idx, %{frames_size: n} = data}) when idx < @header_size + n - 1 do
    {:cont, {idx + 1, Map.update(data, :reversed_frames_bytes, [byte], &[byte|&1])}}
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
    <<id::binary-4, frame_size::integer-32, _flag_bytes::binary-2>> = header
    <<raw_encoded_frame::binary-size(frame_size), binary::binary>> = binary
    <<encoding::integer-8, frame_remainder::binary>> = raw_encoded_frame

    frame =
      case encoding do
        0 -> frame_remainder |> unterminate_gently(<<0>>)
        1 -> frame_remainder |> unterminate_gently(<<0, 0>>) |> decode_utf16()
        _ -> raw_encoded_frame
      end

    tuple = decode_frame({id, frame})

    decode_frames(binary, [tuple | acc])
  end

  defp decode_utf16(<<bom::binary-2, binary::binary>>) do
    {encoding, _} = :unicode.bom_to_encoding(bom)
    binary |> :unicode.characters_to_binary(encoding)
  end

  defp decode_header_flags(binary) do
    <<unsync::size(1), ext::size(1), experimental::size(1), _::bits>> = binary
    %{
      unsynchronization: unsync,
      extended_header: ext,
      experimental: experimental
    }
  end

  defp decode_frame({"TXXX" = key, value}) do
    [subkey, subvalue] = value |> String.split(<<0>>, parts: 2)
    {key, {subkey, subvalue}}
  end
  defp decode_frame({"PRIV" = key, value}) do
    [subkey, subvalue] = value |> String.split(<<0>>, parts: 2)
    decoded_subvalue = :binary.decode_unsigned(subvalue, :little)
    {key, {subkey, {subvalue, decoded_subvalue}}}
  end
  defp decode_frame(tuple), do: tuple

  defp strip_zero_padding(binary, acc \\ <<>>)
  defp strip_zero_padding(<<>>, acc), do: acc
  defp strip_zero_padding(<<0>>, acc), do: acc
  defp strip_zero_padding(<<c, binary::binary>>, acc), do: strip_zero_padding(binary, acc <> <<c>>)

  defp unterminate_gently(binary, terminator, acc \\ <<>>)
  defp unterminate_gently(<<>>, _terminator, acc), do: acc
  defp unterminate_gently(terminator, terminator, acc), do: acc
  defp unterminate_gently(<<c>> <> binary, terminator, acc), do: unterminate_gently(binary, terminator, acc <> <<c>>)

  defp unpack_7bit_list(list) do
    Enum.reduce(list, 0, & (&2 <<< 7) + &1)
  end

  defp visualize(binary) do
    binary
    |> String.codepoints
    |> Stream.chunk(16)
    |> Enum.take(32)
    |> Enum.each(fn l -> l |> Enum.map(&inspect/1) |> Enum.join(" ") |> IO.puts end)
  end
end
