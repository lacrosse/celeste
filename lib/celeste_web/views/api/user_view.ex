defmodule CelesteWeb.API.UserView do
  @spec render(binary, %{user: %Celeste.Social.User{}}) :: %{username: binary}
  def render("show.json", %{user: user}) do
    %{username: user.username}
  end
end
