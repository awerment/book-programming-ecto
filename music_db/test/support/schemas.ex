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

          # belongs_to(:album, Album)
        end
      end
    end
  end

  defmacro __using__(:artist) do
    quote do
      defmodule Artist do
        use Ecto.Schema

        schema "artists" do
          field(:name)
          field(:birth_date, :date)
          field(:death_date, :date)
          timestamps()

          # has_many(:albums, Album)
          # has_many(:tracks, through: [:albums, :tracks])
        end
      end
    end
  end
end
