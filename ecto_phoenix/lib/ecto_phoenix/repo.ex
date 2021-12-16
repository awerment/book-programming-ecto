defmodule EctoPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :ecto_phoenix,
    adapter: Ecto.Adapters.Postgres
end
