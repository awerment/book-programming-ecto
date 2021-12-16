defmodule EctoPhoenix.Repo.Migrations.AddAddressToUsersTable do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :addresses, {:array, :map}
    end
  end
end
