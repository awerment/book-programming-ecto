defmodule Schema05Test do
  use MusicDB.DataCase

  defmodule Track do
    use Ecto.Schema

    schema "tracks" do
      field(:title, :string)
      field(:duration, :integer)
      field(:index, :integer)
      field(:number_of_plays, :integer)
      timestamps()
    end
  end

  test "comparison: delete_all with table name" do
    assert {33, nil} = Repo.delete_all("tracks")
  end

  test "comparison: delete_all with query(able)" do
    assert {1, nil} =
             from(t in "tracks", where: t.title == "Autumn Leaves")
             |> Repo.delete_all()
  end

  test "delete accepts a single schema struct" do
    track = Repo.get_by(Track, title: "The Moontrane")
    {:ok, deleted_track} = Repo.delete(track)
    assert track.id == deleted_track.id
  end
end
