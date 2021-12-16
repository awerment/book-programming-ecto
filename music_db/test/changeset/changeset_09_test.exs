defmodule Changeset09Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.{Album, Artist}

  describe "changesets: working with associations" do
    test "creating a new (empty) album for an artist" do
      artist = Repo.get_by(Artist, name: "Miles Davis")
      new_album = Ecto.build_assoc(artist, :albums)

      assert %Album{} = new_album
      # id of the association is set
      assert new_album.artist_id == artist.id
      # the record itself is (of course) not yet inserted, so the id field is empty
      refute new_album.id
    end

    test "creating a new album for an artist, populating its fields" do
      artist = Repo.get_by(Artist, name: "Miles Davis")
      album = Ecto.build_assoc(artist, :albums, title: "Miles Ahead")

      assert %Album{} = album
      assert album.artist_id == artist.id
      assert "Miles Ahead" == album.title
      refute album.id
    end

    test "creating and inserting a new album for an artist" do
      artist = Repo.one!(from(a in Artist, where: a.name == "Miles Davis", preload: :albums))
      albums = Enum.map(artist.albums, & &1.title)
      refute "Miles Ahead" in albums

      {:ok, album} =
        artist
        |> Ecto.build_assoc(:albums, title: "Miles Ahead")
        |> Repo.insert()

      assert %Album{} = album
      assert album.artist_id == artist.id
      assert "Miles Ahead" == album.title
      assert album.id

      # reloading the artist with his albums
      artist = Repo.one(from(a in Artist, where: a.name == "Miles Davis", preload: :albums))
      albums = Enum.map(artist.albums, & &1.title)
      assert "Miles Ahead" in albums
    end
  end
end
