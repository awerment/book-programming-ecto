defmodule Query01Test do
  use MusicDB.DataCase, async: true

  test "using the query dsl with keyword & macro syntax" do
    _sql = """
    SELECT t.id, t.title, a.title
    FROM tracks t
    JOIN albums a ON t.album_id = t.id
    WHERE t.duraction > 900;
    """

    expected = [
      [6, "If I Were A Bell", "Cookin' At The Plugged Nickel"],
      [10, "No Blues", "Cookin' At The Plugged Nickel"]
    ]

    keyword_query =
      from(t in "tracks",
        join: a in "albums",
        on: a.id == t.album_id,
        where: t.duration > 900,
        select: [t.id, t.title, a.title]
      )

    assert expected == Repo.all(keyword_query)

    macro_query =
      "tracks"
      |> join(:inner, [t], a in "albums", on: a.id == t.album_id)
      |> where([t, a], t.duration > 900)
      |> select([t, a], [t.id, t.title, a.title])

    assert expected == Repo.all(macro_query)
  end

  test "inspecting the generated SQL select statement" do
    query = from("artists", select: [:name])

    expected = ~S(SELECT a0."name" FROM "artists" AS a0)

    {sql_string, _} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
    assert expected == sql_string

    # can also be called directly from Repo module
    {sql_string, _} = Repo.to_sql(:all, query)
    assert expected == sql_string
  end

  test "selecting with Repo.all" do
    query = from("artists", select: [:name])
    expected = [%{name: "Miles Davis"}, %{name: "Bill Evans"}, %{name: "Bobby Hutcherson"}]
    assert expected == Repo.all(query)
  end

  test "omitting select option in from() raises an error (if working without schemas)" do
    query = from("artists")

    assert_raise Ecto.QueryError, fn ->
      Repo.all(query)
    end
  end

  test "using prefixes to specify schema (when using postgres)" do
    query = from("artists", prefix: "public", select: [:name])
    expected = [%{name: "Miles Davis"}, %{name: "Bill Evans"}, %{name: "Bobby Hutcherson"}]
    assert expected == Repo.all(query)

    assert_raise Postgrex.Error, fn ->
      query = from("artists", prefix: "invalid", select: [:name])
      Repo.all(query)
    end
  end
end
