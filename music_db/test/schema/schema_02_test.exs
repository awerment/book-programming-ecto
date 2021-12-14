defmodule Schema02Test do
  use MusicDB.DataCase, async: true
  use Support.Schemas, :track

  test "annoyances when working with schema-less queries" do
    # notice we need to typecast the parameter and also specify a select clause
    artist_id = "1"

    schemaless_query =
      from(a in "artists", where: [id: type(^artist_id, :integer)], select: [:name])

    assert [%{name: "Miles Davis"}] == Repo.all(schemaless_query)

    # raises because of invalid parameter type
    assert_raise DBConnection.EncodeError, fn ->
      from(a in "artists", where: [id: ^artist_id], select: [:name])
      |> Repo.all()
    end

    # raises because of missing select clause
    assert_raise Ecto.QueryError, fn ->
      from(a in "artists", where: [id: type(^artist_id, :integer)])
      |> Repo.all()
    end
  end

  test "parameters are auto-typecast when using schemas" do
    track_id = "1"
    query = from(Track, where: [id: ^track_id])
    result = Repo.all(query)

    assert 1 == length(result)
    # returned records are schema structs
    assert [%Track{}] = result
  end

  test "select clause can still be specified" do
    query = from(Track, where: [id: 1], select: [:title])
    result = [track] = Repo.all(query)

    assert 1 == length(result)
    assert %Track{} = track

    # only selected fields are populated
    assert track.title != nil
    assert track.id == nil
  end

  test "query bindings work the same with schema-based queries" do
    query = from(t in Track, where: t.id == 1)

    named_bindings = from(t in Track, as: :tracks, where: t.id == 1)
    assert has_named_binding?(named_bindings, :tracks)
  end
end
