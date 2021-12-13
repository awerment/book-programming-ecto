defmodule Query02Test do
  use MusicDB.DataCase, async: true

  test "using :where option" do
    query = from("artists", where: [name: "Bill Evans"], select: [:id, :name])
    expected = [%{name: "Bill Evans", id: 2}]
    assert expected == Repo.all(query)
  end

  test "using variables/expressions in parameters requires the pin operator ^" do
    artist_name = "Bill Evans"
    query = from("artists", where: [name: ^artist_name], select: [:id, :name])
    expected = [%{name: "Bill Evans", id: 2}]
    assert expected == Repo.all(query)
  end

  test "using complex expressions in parameters with the pin operator ^" do
    query = from("artists", where: [name: ^("Bill" <> " " <> "Evans")], select: [:id, :name])
    expected = [%{name: "Bill Evans", id: 2}]
    assert expected == Repo.all(query)
  end
end
