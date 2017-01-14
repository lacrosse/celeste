defmodule Zongora.LayoutView do
  use Zongora.Web, :view

  def title(conn) do
    case conn.assigns[:page_title] do
      nil -> "Celeste"
      string -> "#{string} on Celeste"
    end
  end
end
