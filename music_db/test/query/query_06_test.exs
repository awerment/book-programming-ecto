defmodule Query06Test do
  use MusicDB.DataCase, async: true

  test "using 'like' query expression" do
    query = from(a in "artists", where: like(a.name, "Miles%"), select: [:id, :name])

    expected = [%{name: "Miles Davis", id: 1}]
    assert expected == Repo.all(query)
  end

  test "using 'is_nil' query expression" do
    query = from(a in "artists", where: is_nil(a.name), select: [:id, :name])
    expected = []
    assert expected == Repo.all(query)

    query = from(a in "artists", where: not is_nil(a.name), select: [:id, :name])
    assert 3 == length(Repo.all(query))
  end

  test "using ago() in timestamp comparison query expressions" do
    query = from(a in "artists", where: a.inserted_at < ago(1, "year"), select: [:id, :name])

    assert [] == Repo.all(query)
  end
end
