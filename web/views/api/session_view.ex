defmodule Celeste.API.SessionView do
  def render("show.json", _) do
    %{user: %{username: "lacrosse"}}
  end
end
