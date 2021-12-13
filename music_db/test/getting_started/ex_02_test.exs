defmodule GettingStarted.Ex02Test do
  use MusicDB.DataCase, async: true

  test "insert_all for a single record" do
    assert {1, nil} == Repo.insert_all("artists", [[name: "John Coltrane"]])

    assert {1, nil} ==
             Repo.insert_all("artists", [[name: "John Coltrane", inserted_at: DateTime.utc_now()]])
  end

  test "insert_all for multiple records" do
    assert {2, nil} ==
             Repo.insert_all("artists", [
               [name: "Max Roach", inserted_at: DateTime.utc_now()],
               [name: "Art Blakey", inserted_at: DateTime.utc_now()]
             ])
  end

  test "insert_all using maps instead of keyword lists" do
    assert {2, nil} ==
             Repo.insert_all("artists", [
               %{name: "Max Roach", inserted_at: DateTime.utc_now()},
               %{name: "Art Blakey", inserted_at: DateTime.utc_now()}
             ])
  end

  test "update_all" do
    # 3 artists exist in the initially seeded database
    # (no changes are persisted between tests)
    assert {3, nil} == Repo.update_all("artists", set: [updated_at: DateTime.utc_now()])
  end

  test "delete_all" do
    # again, 33 records exist in the intitially seeded database
    assert {33, nil} == Repo.delete_all("tracks")
  end
end
