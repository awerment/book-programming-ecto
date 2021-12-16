defmodule Transactions01Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.{Artist, Log}

  test "case: inserting a record and a correspoding log without a transaction" do
    artist = %Artist{name: "Johnny Hodges"}
    assert {:ok, _artist} = Repo.insert(artist)
    assert {:ok, _log} = Repo.insert(Log.changeset_for_insert(artist))
  end

  test "case: if log insert fails, the artist still persists in the db" do
    artist = %Artist{name: "Johnny Hodges"}
    assert {:ok, _artist} = Repo.insert(artist)

    assert_raise FunctionClauseError, fn ->
      Repo.insert!(nil)
    end

    assert %Artist{name: "Johnny Hodges"} = Repo.get_by(Artist, name: "Johnny Hodges")
  end

  test "inserting a record and a corresponding log in a transaction" do
    artist = %Artist{name: "Johnny Hodges"}

    # returns the result of the last statement
    assert {:ok, _log} =
             Repo.transaction(fn ->
               Repo.insert!(artist)
               Repo.insert!(Log.changeset_for_insert(artist))
             end)
  end

  test "case: data is not modified if one of the operations in a transactions failes" do
    artist = %Artist{name: "Ben Webster"}

    assert_raise FunctionClauseError, fn ->
      Repo.transaction(fn ->
        Repo.insert!(artist)
        Repo.insert!(nil)
      end)
    end

    # make sure the artist was not inserted
    assert nil == Repo.get_by(Artist, name: "Ben Webster")
  end
end
