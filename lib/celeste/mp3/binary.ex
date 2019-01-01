defmodule Celeste.MP3.Binary do
  def visualize(binary) when is_binary(binary) do
    binary
    |> String.codepoints()
    |> Stream.chunk_every(16)
    |> Enum.take(32)
    |> Enum.each(fn l -> l |> Enum.map(&inspect/1) |> Enum.join(" ") |> IO.puts() end)
  end
end
