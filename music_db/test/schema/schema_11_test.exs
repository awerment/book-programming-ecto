defmodule Schema11Test do
  use MusicDB.DataCase

  defmodule Track do
    use Ecto.Schema

    schema "tracks" do
      field(:title, :string)
      field(:index, :integer)
      timestamps()

      belongs_to(:album, Schema11Test.Album)
    end
  end

  defmodule Album do
    use Ecto.Schema

    schema "albums" do
      field(:title, :string)
      timestamps()

      has_many(:tracks, Schema11Test.Track)
      belongs_to(:artist, Schema11Test.Artist)
      many_to_many(:genres, Schema11Test.Genre, join_through: "albums_genres")
    end
  end

  defmodule Artist do
    use Ecto.Schema

    schema "artists" do
      field(:name, :string)
      timestamps()

      has_many(:albums, Schema11Test.Album)
    end
  end

  defmodule Genre do
    use Ecto.Schema

    schema "genres" do
      field(:name, :string)
      timestamps()

      many_to_many(:albums, Schema11Test.Album, join_through: "albums_genres")
    end
  end

  test "(for comparison) inserting with insert_all" do
    assert {1, nil} == Repo.insert_all(Artist, [[name: "Miles Davis"]])
  end

  test "(for comparison) inserting with insert_all & returning" do
    assert {1, [%{id: _}]} = Repo.insert_all(Artist, [[name: "Miles Davis"]], returning: [:id])
  end

  test "(for comparison) inserting with schema struct" do
    assert {:ok, %Artist{name: "Miles Davis"}} = Repo.insert(%Artist{name: "Miles Davis"})
  end

  test "inserting nested schema structs" do
    input = %Artist{
      name: "John Coltrane",
      albums: [
        %Album{title: "A Love Supreme"}
      ]
    }

    assert {:ok, %Artist{name: "John Coltrane", albums: [%Album{title: "A Love Supreme"}]}} =
             Repo.insert(input)
  end

  test "inserting deeply nested schema structs" do
    input = %Artist{
      name: "John Coltrane",
      albums: [
        %Album{
          title: "A Love Supreme",
          tracks: [
            %Track{title: "Part 1: Acknowledgement", index: 1},
            %Track{title: "Part 2: Resolution", index: 2},
            %Track{title: "Part 3: Pursuance", index: 3},
            %Track{title: "Part 4: Psalm", index: 4}
          ],
          genres: [
            %Genre{name: "spiritual jazz"}
          ]
        }
      ]
    }

    assert {:ok, _artist} = Repo.insert(input)
  end
end
