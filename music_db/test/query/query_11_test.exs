defmodule Query11Test do
  use MusicDB.DataCase, async: true

  test "selecting from previously defined queries" do
    albums_by_miles =
      from(a in "albums",
        join: ar in "artists",
        on: ar.id == a.artist_id,
        where: ar.name == "Miles Davis"
      )

    albums_query = from(a in albums_by_miles, order_by: a.id, select: a.title)
    expected = ["Kind Of Blue", "Cookin' At The Plugged Nickel"]
    assert expected == Repo.all(albums_query)

    # bindings must appear in the order they were defined (if used), but can be renamed
    albums_query = from([a, ar] in albums_by_miles, order_by: a.id, select: a.title)
    assert expected == Repo.all(albums_query)

    invalid_bindins_query = from([ar, a] in albums_by_miles, order_by: a.id, select: a.title)

    assert_raise Postgrex.Error, fn ->
      assert expected == Repo.all(invalid_bindins_query)
    end

    renamed_bindings_query =
      from(albums in albums_by_miles, order_by: albums.id, select: albums.title)

    assert expected == Repo.all(renamed_bindings_query)
  end

  test "composing queries" do
    albums_by_miles =
      from(a in "albums",
        join: ar in "artists",
        on: ar.id == a.artist_id,
        where: ar.name == "Miles Davis"
      )

    tracks_query =
      from(a in albums_by_miles, join: t in "tracks", on: t.album_id == a.id, select: t.title)

    assert "No Blues" in Repo.all(tracks_query)
  end

  test "using named bindings in queries" do
    albums_by_miles_named =
      from(a in "albums",
        as: :albums,
        join: ar in "artists",
        as: :artists,
        on: ar.id == a.artist_id,
        where: ar.name == "Miles Davis"
      )

    tracks_query =
      from([albums: a] in albums_by_miles_named,
        join: t in "tracks",
        on: t.album_id == a.id,
        select: t.title
      )

    assert "No Blues" in Repo.all(tracks_query)
  end

  test "when using named bindings, binding order does not matter" do
    albums_by_miles_named =
      from(a in "albums",
        as: :albums,
        join: ar in "artists",
        as: :artists,
        on: ar.id == a.artist_id,
        where: ar.name == "Miles Davis"
      )

    albums_query =
      from([artists: ar, albums: a] in albums_by_miles_named, select: [ar.name, a.title])

    assert ["Miles Davis", "Kind Of Blue"] in Repo.all(albums_query)
  end

  test "checking if a query has a named binding" do
    albums_by_miles_named =
      from(a in "albums",
        as: :albums,
        join: ar in "artists",
        as: :artists,
        on: ar.id == a.artist_id,
        where: ar.name == "Miles Davis"
      )

    assert has_named_binding?(albums_by_miles_named, :albums)
    assert has_named_binding?(albums_by_miles_named, :artists)
    refute has_named_binding?(albums_by_miles_named, :tracks)
  end
end
