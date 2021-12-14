defmodule Query09Test do
  use MusicDB.DataCase, async: true

  test "joining tables" do
    query =
      from(a in "albums",
        join: t in "tracks",
        on: t.album_id == a.id,
        where: t.duration > 900,
        order_by: a.id,
        select: [a.title, t.title]
      )

    expected = [
      ["Cookin' At The Plugged Nickel", "If I Were A Bell"],
      ["Cookin' At The Plugged Nickel", "No Blues"]
    ]

    assert expected == Repo.all(query)
  end

  test "joining tables, selecting into a map with descriptive key names" do
    query =
      from(a in "albums",
        join: t in "tracks",
        on: t.album_id == a.id,
        where: t.duration > 900,
        order_by: a.id,
        select: %{album: a.title, track: t.title}
      )

    expected = [
      %{album: "Cookin' At The Plugged Nickel", track: "If I Were A Bell"},
      %{album: "Cookin' At The Plugged Nickel", track: "No Blues"}
    ]

    assert expected == Repo.all(query)
  end

  test "using prefixes in joins" do
    query =
      from(a in "albums",
        prefix: "public",
        join: t in "tracks",
        # this could be a different prefix if the "tracks" table was in a different schema
        prefix: "public",
        on: t.album_id == a.id,
        where: t.duration > 900,
        order_by: a.id,
        select: %{album: a.title, track: t.title}
      )

    expected = [
      %{album: "Cookin' At The Plugged Nickel", track: "If I Were A Bell"},
      %{album: "Cookin' At The Plugged Nickel", track: "No Blues"}
    ]

    assert expected == Repo.all(query)
  end

  test "using more than one join" do
    query =
      from(a in "albums",
        join: t in "tracks",
        on: t.album_id == a.id,
        join: ar in "artists",
        on: ar.id == a.artist_id,
        where: t.duration > 900,
        order_by: a.id,
        select: %{album: a.title, track: t.title, artist: ar.name}
      )

    expected = [
      %{album: "Cookin' At The Plugged Nickel", track: "If I Were A Bell", artist: "Miles Davis"},
      %{album: "Cookin' At The Plugged Nickel", track: "No Blues", artist: "Miles Davis"}
    ]

    assert expected == Repo.all(query)
  end
end
