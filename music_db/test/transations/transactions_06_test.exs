defmodule Transactions06Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.{Artist, Genre}
  alias Ecto.Multi
  import ExUnit.CaptureIO

  test "capturing errors with multi" do
    artist = Repo.insert!(%Artist{name: "Johnny Hodges"})
    artist_changeset = Artist.changeset(artist, %{name: "John Cornelius Hodges"})
    invalid_changeset = Artist.changeset(%Artist{}, %{name: nil})

    multi =
      Multi.new()
      |> Multi.update(:artist, artist_changeset)
      |> Multi.insert(:invalid, invalid_changeset)

    assert {:error, :invalid, changeset, changes_so_far} = Repo.transaction(multi)
    assert ["can't be blank"] == errors_on(changeset).name
    # one could expect the result of the successful first operation, :artist, to show up here
    # but: before running the transaction, Ecto checks if any of the changesets are invalid
    # if there are any, the database is not hit in the first place
    assert %{} == changes_so_far

    assert nil == Repo.get_by(Artist, name: "Johnny Cornelius Hodges")
    assert %Artist{name: "Johnny Hodges"} = Repo.get_by(Artist, name: "Johnny Hodges")

    # having the result of the multi, we can respond to each outcome separately
    {result, io} =
      with_io(fn ->
        case Repo.transaction(multi) do
          {:ok, _results} ->
            IO.puts("All operations were successful.")

          {:error, :artist, changeset, _changes} ->
            IO.puts("Artist update failed.")
            IO.inspect(changeset.errors)

          {:error, :invalid, changeset, _changes} ->
            IO.puts("Invalid operation failed")
            IO.inspect(changeset.errors)
        end
      end)

    assert io =~ "Invalid operation failed"
  end

  test "inspecting list of changes so far" do
    artist = Repo.insert!(%Artist{name: "Johnny Hodges"})
    artist_changeset = Artist.changeset(artist, %{name: "John Cornelius Hodges"})
    # jazz genre already exists
    genre_changeset =
      %Genre{}
      |> cast(%{name: "jazz"}, [:name])
      |> unique_constraint(:name)

    multi =
      Multi.new()
      |> Multi.update(:artist, artist_changeset)
      |> Multi.insert(:bad_genre, genre_changeset)

    assert {:error, :bad_genre, genre_changeset, %{artist: updated_artist}} =
             Repo.transaction(multi)

    assert "John Cornelius Hodges" == updated_artist.name
    assert ["has already been taken"] == errors_on(genre_changeset).name

    # the changes so far are not persisted, because the multi as a whole failed
    assert nil == Repo.get_by(Artist, name: "John Cornelius Hodges")
  end

  test "case: multi does _not_ catch raised errors if used without changesets" do
    assert_raise Postgrex.Error, fn ->
      Multi.new()
      |> Multi.insert(:artist, %Artist{})
      |> Repo.transaction()
    end
  end
end
