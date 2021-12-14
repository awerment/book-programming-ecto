defmodule Support.Schemas do
  defmacro __using__(:track) do
    quote do
      defmodule Track do
        use Ecto.Schema

        schema "tracks" do
          field(:title, :string)
          field(:duration, :integer)
          field(:index, :integer)
          field(:number_of_plays, :integer)
          timestamps()
        end
      end
    end
  end
end
