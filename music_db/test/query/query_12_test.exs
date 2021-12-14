defmodule Query12Test do
  use MusicDB.DataCase, async: true

  test "using functions to compose queries" do
    query =
      "albums"
      |> by_artist("Miles Davis")
      |> with_tracks_longer_than(720)
      |> title_only()

    assert ["Cookin' At The Plugged Nickel"] == Repo.all(query)
  end

  defp by_artist(query, artist_name) do
    from(a in query,
      join: ar in "artists",
      on: ar.id == a.artist_id,
      where: ar.name == ^artist_name
    )
  end

  defp with_tracks_longer_than(query, duration) do
    from(
      a in query,
      join: t in "tracks",
      on: t.album_id == a.id,
      where: t.duration > ^duration,
      distinct: true
    )
  end

  defp title_only(query) do
    from(a in query, select: a.title)
  end
end
