defmodule Schema03Test do
  use MusicDB.DataCase, async: true

  test "when _not_ to use schemas (as return types) : special, one-off queries that return data in a custom form" do
    query =
      from(a in "artists",
        join: al in "albums",
        on: al.artist_id == a.id,
        group_by: a.name,
        order_by: a.name,
        select: %{artist: a.name, number_of_albums: count(al.id)}
      )

    expected = [
      %{artist: "Bill Evans", number_of_albums: 2},
      %{artist: "Bobby Hutcherson", number_of_albums: 1},
      %{artist: "Miles Davis", number_of_albums: 2}
    ]

    assert expected == Repo.all(query)
  end
end
