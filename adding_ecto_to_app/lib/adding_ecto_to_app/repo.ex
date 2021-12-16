defmodule AddingEctoToApp.Repo do
  use Ecto.Repo,
    otp_app: :adding_ecto_to_app,
    adapter: Ecto.Adapters.Postgres
end
