defmodule Query07Test do
  use MusicDB.DataCase, async: true

  test "using fragment() to insert raw sql into query" do
    query =
      from(a in "artists",
        where: fragment("lower(?)", a.name) == "miles davis",
        select: [:id, :name]
      )

    assert [%{id: 1, name: "Miles Davis"}] == Repo.all(query)

    assert {~S[SELECT a0."id", a0."name" FROM "artists" AS a0 WHERE (lower(a0."name") = 'miles davis')],
            []} ==
             Repo.to_sql(:all, query)
  end

  defmacro lower(arg) do
    quote do
      fragment("lower(?)", unquote(arg))
    end
  end

  test "using custom macros to wrap/simplify usage of fragment" do
    query = from(a in "artists", where: lower(a.name) == "miles davis", select: [:id, :name])
    assert [%{id: 1, name: "Miles Davis"}] == Repo.all(query)
  end
end
