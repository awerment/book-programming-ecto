import Config

config :adding_ecto_to_app, AddingEctoToApp.Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :adding_ecto_to_app, AddingEctoToApp.OtherRepo,
  database: "postgres_other",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :adding_ecto_to_app,
  ecto_repos: [
    AddingEctoToApp.Repo,
    AddingEctoToApp.OtherRepo
  ]
