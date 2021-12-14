defmodule Schem01Test do
  use MusicDB.DataCase, async: true
  use Support.Schemas, :track

  test "fetch all tracks using schema" do
    assert 33 == length(Repo.all(Track))
  end
end
