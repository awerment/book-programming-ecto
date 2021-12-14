defmodule Query08Test do
  use MusicDB.DataCase, async: true

  test "using union to combine query results" do
    tracks_query = from(t in "tracks", select: [:title])
    albums_query = from(a in "albums", select: [:title])

    union_query = from(a in albums_query, union: ^tracks_query)

    num_of_tracks = Repo.aggregate(tracks_query, :count, :title)
    num_of_albums = Repo.aggregate(albums_query, :count, :title)
    num_of_union = Repo.aggregate(union_query, :count, :title)

    assert num_of_tracks < num_of_union
    assert num_of_albums < num_of_union
    # there is some overlap in album and track titles
    assert num_of_tracks + num_of_albums > num_of_union
  end

  test "using union_all to combine query results" do
    tracks_query = from(t in "tracks", select: [:title])
    albums_query = from(a in "albums", select: [:title])

    union_query = from(a in albums_query, union_all: ^tracks_query)

    num_of_tracks = Repo.aggregate(tracks_query, :count, :title)
    num_of_albums = Repo.aggregate(albums_query, :count, :title)

    num_of_union = Repo.aggregate(union_query, :count, :title)

    assert num_of_tracks < num_of_union
    assert num_of_albums < num_of_union
    # there is some overlap in album and track titles
    # but in this case, we use union_all, so we get duplicates as well
    assert num_of_tracks + num_of_albums == num_of_union
  end

  test "using intersect to get album titles that are track titles as well" do
    tracks_query = from(t in "tracks", select: [:title])
    albums_query = from(a in "albums", select: [:title])

    intersect_query = from(a in albums_query, intersect: ^tracks_query)

    assert [%{title: "You Must Believe In Spring"}] ==
             Repo.all(intersect_query) |> IO.inspect(label: "intersect")
  end

  test "using except to get album titles that are not also track titles" do
    tracks_query = from(t in "tracks", select: [:title])
    albums_query = from(a in "albums", select: [:title])
    except_query = from(a in albums_query, except: ^tracks_query)

    assert 4 == length(Repo.all(except_query))
  end

  test "using order by" do
    query = from(a in "artists", select: [a.name], order_by: [a.name])
    expected = [["Bill Evans"], ["Bobby Hutcherson"], ["Miles Davis"]]
    assert expected == Repo.all(query)

    query = from(a in "artists", select: [a.name], order_by: [desc: a.name])
    expected = [["Miles Davis"], ["Bobby Hutcherson"], ["Bill Evans"]]
    assert expected == Repo.all(query)
  end

  test "using multiple columns in order by" do
    # album_id, index (both ascending)
    query =
      from(t in "tracks", select: [t.album_id, t.index, t.title], order_by: [t.album_id, t.index])

    [first, second | _rest] = Repo.all(query)
    assert [1, 1, _] = first
    assert [1, 2, _] = second

    # album_id desc, index asc
    query =
      from(t in "tracks",
        select: [t.album_id, t.index, t.title],
        order_by: [desc: t.album_id, asc: t.index]
      )

    [first, second | _rest] = Repo.all(query)
    assert [5, 1, _] = first
    assert [5, 2, _] = second

    # index asc, album asc
    query =
      from(t in "tracks",
        select: [t.album_id, t.index, t.title],
        order_by: [t.index, t.album_id]
      )

    [first, second | _rest] = Repo.all(query)
    assert [1, 1, _] = first
    assert [2, 1, _] = second
  end

  test "accounting for nulls when ordering" do
    Repo.insert_all("tracks", [
      [
        title: "No Index",
        index: 100,
        album_id: 1,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now(),
        duration: nil
      ]
    ])

    query =
      from(t in "tracks",
        select: [t.album_id, t.index, t.duration],
        order_by: [asc: t.album_id, asc_nulls_first: t.duration]
      )

    [first | _rest] = Repo.all(query)
    assert [1, 100, nil] = first
  end

  test "using group by & sum" do
    query =
      from(t in "tracks",
        select: [t.album_id, sum(t.duration)],
        order_by: t.album_id,
        group_by: t.album_id
      )

    expected = [[1, 2619], [2, 4491], [3, 3456], [4, 2540], [5, 3057]]
    assert expected == Repo.all(query)
  end

  test "filtering grouped query with having" do
    query =
      from(t in "tracks",
        select: [t.album_id, sum(t.duration)],
        order_by: t.album_id,
        group_by: t.album_id,
        having: sum(t.duration) > 3600
      )

    expected = [[2, 4491]]
    assert expected == Repo.all(query)
  end
end
