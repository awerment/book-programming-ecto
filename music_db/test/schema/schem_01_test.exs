defmodule Schem01Test do
  use MusicDB.DataCase, async: true

  defmodule Track do
    use Ecto.Schema

    schema "tracks" do
      field(:title, :string)
      field(:duration, :integer)
      field(:index, :integer)
      field(:number_of_plays, :integer)
      timestamps()

      # belongs_to(:album, Album)
    end
  end

  test "fetch all tracks using schema" do
    assert 33 == length(Repo.all(Track))
  end
end
