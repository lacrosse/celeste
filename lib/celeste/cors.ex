defmodule Celeste.CORS do
  use Corsica.Router,
    origins: "*",
    allow_headers: [
      "authorization",
      "content-type"
    ]

  resource "/api/assemblages/*"
  resource "/api/*"
end
