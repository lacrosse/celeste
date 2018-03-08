defmodule Celeste.Borkfm do
  alias Celeste.{Borkle, Repo}

  def bork(file, user) do
    %Borkle{}
    |> Borkle.changeset(%{user_id: user.id, file_id: file.id})
    |> Repo.insert!()

    case user.lastfm_key do
      nil ->
        nil
      key ->
        scrobble(key, file)
    end
  end

  defp scrobble(key, file) do
    body = [
      artist: file.id3v2[:TCOM],
      track: file.id3v2[:TIT2],
      api_key: api_key(),
      sk: key
    ]

    body_ = [{:api_sig, sig(body)} | body]

    HTTPotion.post "https://ws.audioscrobbler.com/2.0/?format=json&method=track.scrobble", body: body_
  end

  defp api_key(), do: Application.fetch_env!(:celeste, __MODULE__)[:api_key]

  defp sig(body) do
    body
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Enum.map(fn {k, v} -> "#{k}#{v}" end)
    |> Enum.join()
    |> (&:crypto.hash(:md5, &1)).()
    |> Base.encode16(case: :lower)
  end
end
