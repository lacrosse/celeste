defmodule Celeste.API.FileController do
  use Celeste.Web, :controller

  alias Celeste.{Repo, User, Borkle}
  alias Celeste.File, as: CFile

  def show(conn, %{"id" => jwt}) do
    with {:ok, %{"sub" => sub, "u" => user_id}} <- Guardian.decode_and_verify(jwt),
         {:ok, file} <- Celeste.GuardianSerializer.from_token(sub) do
      [extension|_] = MIME.extensions(file.mime)

      conn =
        conn
        |> put_resp_header("content-type", file.mime)

      case file.mime do
        "audio/" <> _ ->
          case get_req_header(conn, "range") do
            ["bytes=" <> range] ->
              [start, finish] = String.split(range, "-", parts: 2)
              offset = String.to_integer(start)

              conn
              |> put_resp_header("content-range", "bytes #{offset}-#{file.size - 1}/#{file.size}")
              |> put_resp_header("accept-ranges", "bytes")
              |> send_file(206, file.path, offset, file.size - offset)

            _ ->
              user = Repo.get!(User, user_id)

              %Borkle{}
              |> Borkle.changeset(%{user_id: user.id, file_id: file.id})
              |> Repo.insert!()

              conn
              |> put_resp_header("accept-ranges", "bytes")
              |> send_file(200, file.path)
          end
        _ ->
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
end
