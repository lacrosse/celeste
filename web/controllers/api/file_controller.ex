defmodule Celeste.API.FileController do
  use Celeste.Web, :controller

  alias Celeste.{Repo, User, Borkfm}

  def show(conn, %{"id" => jwt}) do
    with {:ok, %{"sub" => sub, "u" => user_id}} <- Guardian.decode_and_verify(jwt),
         {:ok, file} <- Celeste.GuardianSerializer.from_token(sub) do
      conn =
        conn
        |> put_resp_header("content-type", file.mime)

      case file.mime do
        "audio/" <> _ ->
          conn =
            conn
            |> put_resp_header("accept-ranges", "bytes")

          case get_req_header(conn, "range") do
            ["bytes=" <> range] ->
              [start, _] = String.split(range, "-", parts: 2)
              offset = String.to_integer(start)

              conn =
                if offset == 0 do
                  bork(file, user_id)

                  conn
                else
                  conn
                  |> put_resp_header("content-range", "bytes #{offset}-#{file.size - 1}/#{file.size}")
                end

              conn
              |> send_file(206, file.path, offset, file.size - offset)
            _ ->
              bork(file, user_id)
              conn
              |> send_file(200, file.path)
          end
        _ ->
          [extension|_] = MIME.extensions(file.mime)

          conn
          |> put_resp_header("content-disposition", ~s|inline; filename="#{file.sha256}.#{extension}"|)
          |> send_file(200, file.path)
      end
    else
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Poison.encode!(%{errors: ["Unauthenticated"]}))
    end
  end

  defp bork(file, user_id) do
    Borkfm.bork(file, Repo.get!(User, user_id))
  end
end
