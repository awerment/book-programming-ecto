defmodule Changeset03Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.Artist

  test "using the cast function to create changesets from external data" do
    params = %{
      "name" => "Charlie Parker",
      "birth_date" => "1920-08-29",
      "instrument" => "alto sax"
    }

    changeset = cast(%Artist{}, params, [:name, :birth_date])

    assert changeset.changes.name
    assert changeset.changes.birth_date
    # instrument was not given to the list of valid fields, it is omitted
    assert_raise KeyError, fn ->
      assert changeset.changes.instrument
    end
  end

  test "using the empty_values option to specify what to consider as an empty value" do
    params = %{"name" => "Charlie Parker", "birth_date" => "NULL"}
    changeset = cast(%Artist{}, params, [:name, :birth_date], empty_values: ["", "NULL"])

    assert changeset.changes.name
    # birth_date of "NULL" was dropped as an empty value
    assert_raise KeyError, fn ->
      assert changeset.changes.birth_date
    end
  end
end
