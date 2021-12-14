defmodule Query05Test do
  use MusicDB.DataCase

  test "using query bindings to inline where conditions" do
    query = from(a in "artists", where: a.name == "Bill Evans", select: [:id, :name])
    expected = [%{id: 2, name: "Bill Evans"}]
    assert expected == Repo.all(query)
  end
end
