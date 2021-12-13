defmodule Query03Test do
  use MusicDB.DataCase, async: true

  test "pin operator converts pinned expressions to parameters, protecting from SQL injection" do
    artist_name = "Bill Evans"
    query = from("artists", where: [name: ^artist_name], select: [:id, :name])

    expected =
      {~S[SELECT a0."id", a0."name" FROM "artists" AS a0 WHERE (a0."name" = $1)], ["Bill Evans"]}

    assert expected == Repo.to_sql(:all, query)
  end
end
