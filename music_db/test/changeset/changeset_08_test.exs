defmodule Changeset08Test do
  use MusicDB.DataCase, async: true

  describe "using changesets without a schema" do
    test "defining ad-hoc validation 'schema'" do
      form = %{
        artist_name: :string,
        album_title: :string,
        artist_birth_date: :date,
        album_release_date: :date,
        genre: :string
      }

      params = %{
        "artist_name" => "Ella Fitzgerald",
        "album_title" => "",
        "artist_birth_date" => "",
        "album_release_date" => "",
        "genre" => ""
      }

      changeset =
        {%{}, form}
        |> cast(params, Map.keys(form))
        |> validate_in_the_past(:artist_birth_date)
        |> validate_in_the_past(:album_release_date)

      assert changeset.valid?
      # only non-empty fields are put into changeset's changes
      assert %{artist_name: "Ella Fitzgerald"} == changeset.changes
    end
  end

  defp validate_in_the_past(changeset, field) do
    validate_change(changeset, field, fn _field, value ->
      cond do
        is_nil(value) -> []
        Date.compare(value, Date.utc_today()) == :lt -> []
        true -> [{field, "must be in the past"}]
      end
    end)
  end
end
