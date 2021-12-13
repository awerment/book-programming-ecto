defmodule GettingStarted01Test do
  use MusicDB.DataCase
  alias MusicDB.Artist

  test "interacting with repo using schemas" do
    assert {:ok, inserted = %Artist{}} = Repo.insert(%Artist{name: "Dizzy Gillespie"})

    dizzy = Repo.get_by(Artist, name: "Dizzy Gillespie")
    assert inserted.id == dizzy.id

    {:ok, updated} = Repo.update(Ecto.Changeset.change(dizzy, name: "John Birks Gillespie"))
    assert updated.name == "John Birks Gillespie"

    dizzy = Repo.get_by(Artist, name: "John Birks Gillespie")
    assert dizzy.id == inserted.id

    {:ok, deleted} = Repo.delete(dizzy)
    assert deleted.id == inserted.id

    assert nil == Repo.get_by(Artist, name: "John Birks Gillespie")
  end
end
