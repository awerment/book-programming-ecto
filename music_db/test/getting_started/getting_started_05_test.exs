defmodule GettingStarted05Test do
  use MusicDB.DataCase, async: true

  test "customizing the Repo module with own functions" do
    assert 3 == Repo.count("artists")
  end
end
