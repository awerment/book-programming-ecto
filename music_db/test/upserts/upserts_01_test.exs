defmodule Upserts01Test do
  use MusicDB.DataCase, async: true

  describe "schema-less upserts" do
    test "inserting same genre twice causes error" do
      assert {1, nil} == Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska_music"]])

      assert_raise Postgrex.Error, fn ->
        Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska_music"]])
      end
    end

    test "using on_conflict: :nothing does not raise, duplicate insert is dropped silently" do
      assert {1, nil} == Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska_music"]])

      assert {0, nil} ==
               Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska_music"]],
                 on_conflict: :nothing
               )
    end

    test "using on_conflict: :replace without a :conflict_target causes an error" do
      assert {1, nil} == Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska_music"]])

      assert_raise ArgumentError, fn ->
        Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska_music"]], on_conflict: :replace)
      end
    end

    test "success with on_conflict: :replace with the unique column as :conflict_targer" do
      assert {1, nil} == Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska_music"]])

      assert {1, [%{wiki_tag: "Ska"}]} ==
               Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska"]],
                 on_conflict: {:replace, [:wiki_tag]},
                 conflict_target: :name,
                 returning: [:wiki_tag]
               )
    end

    test "running the same command with not actually conflicting record has same effect" do
      assert {1, nil} == Repo.insert_all("genres", [[name: "ska", wiki_tag: "Ska_music"]])

      assert {1, [%{wiki_tag: "Ambient_music"}]} ==
               Repo.insert_all("genres", [[name: "ambient", wiki_tag: "Ambient_music"]],
                 on_conflict: {:replace, [:wiki_tag]},
                 conflict_target: :name,
                 returning: [:wiki_tag]
               )
    end

    test "using a keyword list of update instructions :on_conflict" do
      result =
        Repo.insert_all("genres", [[name: "ambient", wiki_tag: "Ambient_music"]],
          on_conflict: [set: [wiki_tag: "Ambient_music"]],
          conflict_target: :name,
          returning: [:wiki_tag]
        )

      assert {1, [%{wiki_tag: "Ambient_music"}]} == result
    end
  end
end
