defmodule Celeste.API.SessionView do
  def render("show.json", %{user: user, jwt: jwt, exp: exp}) do
    %{
      session: %{
        username: user.username,
        jwt: jwt,
        expires: exp
      }
    }
  end

  def render("error.json", %{message: message}) do
    %{error: message}
  end
end
