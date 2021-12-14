defmodule Schema04 do
  use MusicDB.DataCase
  use Support.Schemas, :artist

  test "for comparison: inserting without schema" do
    assert {1, nil} == Repo.insert_all("artists", [[name: "John Coltrane"]])
  end

  test "inserting with a schema" do
    assert {:ok, artist = %Artist{}} = Repo.insert(%Artist{name: "John Coltrane"})
    assert artist.id
  end

  test "insert_all with a schema" do
    assert {1, nil} == Repo.insert_all(Artist, [[name: "John Coltrane"]])
  end
end
