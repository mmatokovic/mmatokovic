defmodule Mmatokovic.Repo do
  use Ecto.Repo,
    otp_app: :mmatokovic,
    adapter: Ecto.Adapters.Postgres
end
