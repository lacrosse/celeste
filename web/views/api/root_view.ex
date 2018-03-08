defmodule Celeste.API.RootView do
  def render("ping.json", _) do
    %{do: 93}
  end
end
