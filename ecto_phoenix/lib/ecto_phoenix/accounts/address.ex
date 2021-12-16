defmodule EctoPhoenix.Accounts.Address do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :street, :string
    field :city, :string
  end

  def changeset(address, params) do
    address
    |> cast(params, [:street, :city])
  end
end
