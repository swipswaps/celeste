use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :celeste, CelesteWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :guardian, Guardian, secret_key: "secretkey"

# Configure your database
config :celeste, Celeste.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "celeste_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
