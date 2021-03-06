defmodule CelesteWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Celeste.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import CelesteWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint CelesteWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Celeste.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Celeste.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()

    {conn, user} =
      if tags[:auth] do
        user =
          %Celeste.Social.User{}
          |> Celeste.Social.User.create_changeset(%{username: "test", password: "testtest"})
          |> Celeste.Repo.insert!()

        {
          conn
          |> Plug.Test.init_test_session(%{})
          |> Guardian.Plug.api_sign_in(user),
          user
        }
      else
        {conn, nil}
      end

    {:ok, conn: conn, user: user}
  end
end
