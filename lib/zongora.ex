defmodule Celeste do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Celeste.Repo, []),
      supervisor(Celeste.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: Celeste.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Celeste.Endpoint.config_change(changed, removed)
    :ok
  end
end
