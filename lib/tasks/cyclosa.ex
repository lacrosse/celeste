defmodule Mix.Tasks.Cyclosa do
  use Mix.Task

  @shortdoc "Crawl the directory"

  def run([dir]) do
    Celeste.Content.Cyclosa.crawl_dir(dir)
  end
end
