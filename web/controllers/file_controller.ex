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

    conn
    |> put_resp_header("content-type", file.mime)
    |> put_resp_header("content-disposition", ~s|inline; filename="#{response_filename}"|)
    |> send_file(200, file.path)
  end
end
