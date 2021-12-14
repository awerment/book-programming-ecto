defmodule Query14Test do
  use MusicDB.DataCase, async: true

  test "using Ecto.Queryable in writing queries" do
    q = from(t in "tracks", where: t.title == "Autumn Leaves")

    assert {1, nil} == Repo.update_all(q, set: [title: "Autumn Leaves (updated)"])

    # or more Elixir-y:
    result =
      from(t in "tracks", where: t.title == "Autumn Leaves (updated)")
      |> Repo.update_all(set: [title: "Autumn Leaves"])

    assert {1, nil} == result

    result =
      from(t in "tracks", where: t.title == "Autumn Leaves")
      |> Repo.delete_all()

    assert {1, nil} == result
  end
end
