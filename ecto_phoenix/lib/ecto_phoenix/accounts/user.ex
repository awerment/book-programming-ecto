defmodule EctoPhoenix.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias EctoPhoenix.Accounts.Address

  schema "users" do
    field :age, :integer
    field :name, :string
    embeds_one :address, Address

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :age])
    |> validate_required([:name])
    |> cast_embed(:address)
    |> validate_number(:age, greater_than: 0, message: "you are not yet born")
  end
end
