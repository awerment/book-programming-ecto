defmodule Query04Test do
  use MusicDB.DataCase, async: true

  test "using type conversions" do
    # using an incorrect parameter type raises an error
    assert_raise DBConnection.EncodeError, fn ->
      # id field is an integer
      artist_id = "1"
      query = from("artists", where: [id: ^artist_id], select: [:name])
      Repo.all(query)
    end

    artist_id = "1"
    query = from("artists", where: [id: type(^artist_id, :integer)], select: [:name])
    assert [%{name: "Miles Davis"}] == Repo.all(query)
  end
end
