defmodule Query13Test do
  use MusicDB.DataCase, async: true

  test "where clauses are AND-combined" do
    albums_by_miles =
      from(a in "albums",
        join: ar in "artists",
        on: ar.id == a.artist_id,
        where: ar.name == "Miles Davis"
      )

    query =
      from(
        [a, ar] in albums_by_miles,
        where: ar.name == "Bobby Hutcherson",
        select: a.title
      )

    assert [] == Repo.all(query)

    expected =
      inline(~S"""
      SELECT a0."title"
      FROM "albums" AS a0
      INNER JOIN "artists" AS a1 ON a1."id" = a0."artist_id"
      WHERE (a1."name" = 'Miles Davis')
      AND (a1."name" = 'Bobby Hutcherson')
      """)

    assert {^expected, []} = Repo.to_sql(:all, query)
  end

  test "combining where clauses with OR" do
    naive_query =
      from(a in "albums",
        join: ar in "artists",
        on: ar.id == a.artist_id,
        where: ar.name == "Miles Davis" or ar.name == "Bobby Hutcherson",
        order_by: a.id,
        select: %{artist: ar.name, album: a.title}
      )

    albums_by_miles_or_bobby = Repo.all(naive_query)

    # combining with :or_where

    albums_by_miles =
      from(a in "albums",
        join: ar in "artists",
        on: ar.id == a.artist_id,
        where: ar.name == "Miles Davis"
      )

    query =
      from([a, ar] in albums_by_miles,
        or_where: ar.name == "Bobby Hutcherson",
        order_by: a.id,
        select: %{artist: ar.name, album: a.title}
      )

    assert albums_by_miles_or_bobby == Repo.all(query)
  end

  defp inline(multiline_string) do
    multiline_string
    |> String.split(~r/\n/, trim: true)
    |> Enum.join(" ")
  end
end
