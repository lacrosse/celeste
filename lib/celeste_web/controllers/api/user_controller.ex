defmodule CelesteWeb.API.UserController do
  use CelesteWeb, :controller

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    render(conn, "show.json", %{user: user})
  end
end
