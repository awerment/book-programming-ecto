defmodule GettingStarted.Ex04Test do
  use MusicDB.DataCase, async: true

  test "executing raw sql" do
    assert {:ok, result = %Postgrex.Result{}} =
             Repo.query("select name from artists where id = 1")

    assert [["Miles Davis"]] == result.rows
  end
end
