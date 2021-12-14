defmodule Schema10Test do
  use MusicDB.DataCase

  defmodule Track do
    use Ecto.Schema

    schema "tracks" do
      field(:title, :string)
      belongs_to(:album, Schema10Test.Album)
    end
  end

  defmodule Album do
    use Ecto.Schema

    schema "albums" do
      field(:title, :string)
      has_many(:tracks, Schema10Test.Track)
      belongs_to(:artist, Schema10Test.Artist)
    end
  end

  defmodule Artist do
    use Ecto.Schema

    schema "artists" do
      field(:name, :string)
      has_many(:albums, Schema10Test.Album)
    end
  end

  test "associations are not fetched eagerly" do
    album = Repo.get_by(Album, title: "Kind Of Blue")
    assert album.title == "Kind Of Blue"

    assert_raise ArgumentError, fn ->
      assert 0 < length(album.tracks)
    end
  end

  test "preloading up front (still fires 2 queries)" do
    [album] = Repo.all(from(a in Album, where: a.title == "Kind Of Blue", preload: :tracks))
    assert album.title == "Kind Of Blue"
    assert 0 < length(album.tracks)
  end

  test "preloading after the fact (fires 2 queries)" do
    album =
      Album
      |> Repo.get_by(title: "Kind Of Blue")
      |> Repo.preload(:tracks)

    assert album.title == "Kind Of Blue"
    assert 0 < length(album.tracks)
  end

  test "nested preloads" do
    [artist] =
      Repo.all(from(a in Artist, where: a.name == "Miles Davis", preload: [albums: :tracks]))

    assert artist.name == "Miles Davis"
    assert 0 < length(artist.albums)

    [album | _rest] = artist.albums
    assert 0 < length(album.tracks)
  end

  test "to load everything in one query, we need to preload with a join" do
    query =
      from(ar in Artist,
        join: a in assoc(ar, :albums),
        where: ar.name == "Miles Davis",
        preload: [albums: a]
      )

    [artist] = Repo.all(query)

    assert artist.name == "Miles Davis"
    assert 0 < length(artist.albums)
  end

  test "(nested preloads) to load everything in one query, we need to preload with a join" do
    query =
      from(ar in Artist,
        join: a in assoc(ar, :albums),
        join: t in assoc(a, :tracks),
        where: ar.name == "Miles Davis",
        preload: [albums: {a, tracks: t}]
      )

    [artist] = Repo.all(query)

    assert artist.name == "Miles Davis"
    assert 0 < length(artist.albums)

    [album | _rest] = artist.albums
    assert 0 < length(album.tracks)
  end
end
