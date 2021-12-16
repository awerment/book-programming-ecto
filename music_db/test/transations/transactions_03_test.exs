defmodule Transactions03Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.{Artist, Log}

  test "calling non-db actions in a transaction" do
    artist = %Artist{name: "Johnny Hodges"}

    assert {:ok, _result} =
             Repo.transaction(fn ->
               artist_record = Repo.insert!(artist)
               Repo.insert!(Log.changeset_for_insert(artist_record))
               # run last. Ecto does not know how to rollback this action
               SearchEngine.update!(artist_record)
             end)

    assert %Artist{name: "Johnny Hodges"} = Repo.get_by(Artist, name: "Johnny Hodges")
  end

  test "calling non-db actions in a transaction (fail)" do
    artist = %Artist{name: "Johnny Hodges"}

    assert_raise RuntimeError, fn ->
      Repo.transaction(fn ->
        artist_record = Repo.insert!(artist)
        Repo.insert!(Log.changeset_for_insert(artist_record))
        # run last. Ecto does not know how to rollback this action
        SearchEngine.fail!(artist_record)
      end)
    end

    assert nil == Repo.get_by(Artist, name: "Johnny Hodges")
  end
end
