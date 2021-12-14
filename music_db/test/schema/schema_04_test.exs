defmodule Schema04 do
  use MusicDB.DataCase

  defmodule Artist do
    use Ecto.Schema

    schema "artists" do
      field(:name)
      field(:birth_date, :date)
      field(:death_date, :date)
      timestamps()

      has_many(:albums, Schema04.Album)
      has_many(:tracks, through: [:albums, :tracks])
    end
  end

  defmodule Album do
    use Ecto.Schema

    schema "albums" do
      field(:title, :string)
      field(:release_date, :date)

      has_many(:tracks, Schema04.Track)
      belongs_to(:artist, Schema04.Artist)
    end
  end

  test "for comparison: inserting without schema" do
    assert {1, nil} == Repo.insert_all("artists", [[name: "John Coltrane"]])
  end

  test "inserting with a schema" do
    assert {:ok, artist = %Artist{}} = Repo.insert(%Artist{name: "John Coltrane"})
    assert artist.id
  end

  test "insert_all with a schema" do
    assert {1, nil} == Repo.insert_all(Artist, [[name: "John Coltrane"]])
  end
end
