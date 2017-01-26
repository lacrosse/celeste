defmodule Celeste.FileController do
  use Celeste.Web, :controller

  alias Celeste.Repo
  alias Celeste.File, as: ZFile

  def show(conn, %{"id" => base16_sha256}) do
    sha256 =
      case Base.decode16(base16_sha256, case: :lower) do
        {:ok, value} -> value
      end

    file = Repo.get_by!(ZFile, sha256: sha256)

    [extension|_] = MIME.extensions(file.mime)

    response_filename = "#{ZFile.link_param(file)}.#{extension}"

    case file.mime do
      "audio/" <> _ ->
        case get_req_header(conn, "range") do
          ["bytes=" <> range] ->
            [start, finish] = String.split(range, "-", parts: 2)
            offset = String.to_integer(start)

            conn
            |> put_resp_header("content-range", "bytes #{offset}-#{file.size - 1}/#{file.size}")
            |> put_resp_header("content-type", file.mime)
            |> put_resp_header("accept-ranges", "bytes")
            |> send_file(206, file.path, offset, file.size - offset)
          _ ->
            conn
            |> put_resp_header("content-type", file.mime)
            |> put_resp_header("accept-ranges", "bytes")
            |> send_file(200, file.path)
        end
      _ ->
        conn
        |> put_resp_header("content-type", file.mime)
        |> put_resp_header("content-disposition", ~s|inline; filename="#{response_filename}"|)
        |> send_file(200, file.path)
    end
  end
end
