defmodule Upserts02Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.Genre

  describe "performing upserts with schemas" do
    test "inserting duplicate genre with on_conflict: :set may not return updated fields" do
      genre = %Genre{name: "funk", wiki_tag: "Funk"}

      assert {:ok, _record} = Repo.insert(genre)

      assert {:ok, record} =
               Repo.insert(genre,
                 on_conflict: [set: [wiki_tag: "Funk_music"]],
                 conflict_target: :name
               )

      # the returned struct may have old field values
      assert record.wiki_tag == "Funk"

      # but after refetching the record, we can see the field was actually updated
      genre = Repo.get(Genre, record.id)
      assert genre.wiki_tag == "Funk_music"
    end

    test "using on_conflict: :replace_all_except to refresh the returned struct" do
      assert {:ok, _record} = Repo.insert(%Genre{name: "funk", wiki_tag: "Funk"})

      assert {:ok, record} =
               Repo.insert(%Genre{name: "funk", wiki_tag: "Funk_music"},
                 on_conflict: {:replace_all_except, [:id]},
                 conflict_target: :name
               )

      assert record.wiki_tag == "Funk_music"
    end

    test "alternative: using returning: true to return all fields back" do
      genre = %Genre{name: "funk", wiki_tag: "Funk"}
      assert {:ok, _record} = Repo.insert(genre)

      assert {:ok, record} =
               Repo.insert(genre,
                 on_conflict: [set: [wiki_tag: "Funk_music"]],
                 conflict_target: :name,
                 returning: true
               )

      assert record.wiki_tag == "Funk_music"
    end

    defmodule Genre do
      use Ecto.Schema

      schema "genres" do
        field(:name, :string)
        # caution: this will affect all writes, not just upserts
        field(:wiki_tag, :string, read_after_writes: true)
      end
    end

    test "alternative: define field with read_after_writes: true" do
      genre = %Upserts02Test.Genre{name: "funk", wiki_tag: "Funk"}

      assert {:ok, _record} = Repo.insert(genre)

      assert {:ok, record} =
               Repo.insert(genre,
                 on_conflict: [set: [wiki_tag: "Funk_music"]],
                 conflict_target: :name
               )

      assert record.wiki_tag == "Funk_music"
    end
  end
end
