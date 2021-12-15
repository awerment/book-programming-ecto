defmodule Changeset02Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.Artist

  test "using changeset to insert a new artist" do
    changeset = change(%Artist{name: "Charlie Parker"})
    assert {:ok, _} = Repo.insert(changeset)
  end

  test "updating an artist" do
    artist = Repo.get_by(Artist, name: "Bobby Hutcherson")
    changeset = change(artist, name: "Robert Hutcherson")

    assert %{name: "Robert Hutcherson"} == changeset.changes
    assert {:ok, _} = Repo.update(changeset)
  end

  test "adding changes to a changeset" do
    changeset =
      Repo.get_by(Artist, name: "Bobby Hutcherson")
      |> change(name: "Robert Hutcherson")
      |> change(birth_date: ~D[1941-01-27])

    assert %{name: "Robert Hutcherson", birth_date: ~D[1941-01-27]} == changeset.changes
    assert {:ok, _} = Repo.update(changeset)
  end

  test "changing multiple fields at once" do
    changeset =
      Repo.get_by(Artist, name: "Bobby Hutcherson")
      |> change(name: "Robert Hutcherson", birth_date: ~D[1941-01-27])

    assert %{name: "Robert Hutcherson", birth_date: ~D[1941-01-27]} == changeset.changes
    assert {:ok, _} = Repo.update(changeset)
  end
end
