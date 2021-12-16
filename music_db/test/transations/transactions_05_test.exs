defmodule Transactions05Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.{Artist, Log}
  alias Ecto.Multi

  test "using Ecto.Multi for multi-operation transactions" do
    artist = %Artist{name: "Johnny Hodges"}

    multi =
      Multi.new()
      |> Multi.insert(:artist, artist)
      |> Multi.insert(:log, Log.changeset_for_insert(artist))

    result = Repo.transaction(multi)
    assert {:ok, %{artist: %Artist{}, log: %Log{}}} = result
    assert %Artist{name: "Johnny Hodges"} = Repo.get_by(Artist, name: "Johnny Hodges")
  end
end
