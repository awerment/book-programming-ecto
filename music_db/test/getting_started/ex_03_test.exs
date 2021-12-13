defmodule GettingStarted.Ex03Test do
  use MusicDB.DataCase, async: true

  test "insert_all with :returning" do
    result =
      Repo.insert_all("artists", [[name: "Max Roach"], [name: "Art Blakey"]],
        returning: [:id, :name]
      )

    assert {2, [%{id: _a, name: "Max Roach"}, %{id: _b, name: "Art Blakey"}]} = result
  end
end
