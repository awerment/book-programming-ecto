defmodule Transactions07Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.{Artist, Log}
  alias Ecto.Multi

  test "running non-db actions with multi (success)" do
    artist = %Artist{name: "Toshiko Akiyoshi"}

    assert {:ok, changes} =
             Multi.new()
             |> Multi.insert(:artist, artist)
             |> Multi.insert(:log, Log.changeset_for_insert(artist))
             |> Multi.run(:search, fn _repo, changes ->
               SearchEngine.update(changes[:artist])
             end)
             |> Repo.transaction()

    assert %{
             artist: artist = %Artist{},
             log: %Log{},
             search: artist
           } = changes

    assert %Artist{name: "Toshiko Akiyoshi"} = Repo.get_by(Artist, name: "Toshiko Akiyoshi")
  end

  test "running non-db actions with multi (success) using run/5" do
    artist = %Artist{name: "Toshiko Akiyoshi"}

    assert {:ok, changes} =
             Multi.new()
             |> Multi.insert(:artist, artist)
             |> Multi.insert(:log, Log.changeset_for_insert(artist))
             |> Multi.run(:search, SearchEngine, :update, ["extra argument"])
             |> Repo.transaction()

    # explanation for the :search result
    # Multi.run(:search, SearchEngine, :update, ["extra argument"]) calls
    # SearchEngine.update/3 with following arguments: the repo, the changes so far and the "extra argument" string
    # (if the list contained two elements, .update/4 would be called, etc.)
    assert %{
             artist: artist = %Artist{},
             log: %Log{},
             search: {%{artist: artist}, "extra argument"}
           } = changes

    assert %Artist{name: "Toshiko Akiyoshi"} = Repo.get_by(Artist, name: "Toshiko Akiyoshi")
  end

  test "running non-db actions with multi (fail)" do
    artist = %Artist{name: "Toshiko Akiyoshi"}

    assert {:error, :search, "Failed to update search engine", changes} =
             Multi.new()
             |> Multi.insert(:artist, artist)
             |> Multi.insert(:log, Log.changeset_for_insert(artist))
             |> Multi.run(:search, fn _repo, changes ->
               SearchEngine.fail(changes[:artist])
             end)
             |> Repo.transaction()

    assert %{
             artist: %Artist{},
             log: %Log{}
           } = changes

    assert nil == Repo.get_by(Artist, name: "Toshiko Akiyoshi")
  end

  test "inspecting the multi struct" do
    artist = %Artist{name: "Toshiko Akiyoshi"}

    multi =
      Multi.new()
      |> Multi.insert(:artist, artist)
      |> Multi.insert(:log, Log.changeset_for_insert(artist))
      |> Multi.run(:search, SearchEngine, :update, ["extra argument"])

    multi_list = Multi.to_list(multi)

    assert [
             artist: {:insert, _artist_changeset, []},
             log: {:insert, _log_changeset, []},
             search: {:run, {SearchEngine, :update, ["extra argument"]}}
           ] = multi_list
  end
end
