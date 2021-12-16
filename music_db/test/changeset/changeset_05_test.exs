defmodule Changeset05Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.Artist

  test "custom (ad-hoc) validations with validate_change" do
    params = %{"name" => "Thelonius Monk", "birth_date" => "2117-10-10"}

    changeset =
      %Artist{}
      |> cast(params, [:name, :birth_date])
      |> validate_change(:birth_date, fn :birth_date, birth_date ->
        cond do
          is_nil(birth_date) -> []
          Date.compare(birth_date, Date.utc_today()) == :lt -> []
          true -> [birth_date: "must be in the past"]
        end
      end)

    refute changeset.valid?
    assert ["must be in the past"] == errors_on(changeset).birth_date
  end

  test "moving the custom birth_date validation into a separate function" do
    params = %{"name" => "Thelonius Monk", "birth_date" => "2117-10-10"}

    changeset =
      %Artist{}
      |> cast(params, [:name, :birth_date])
      |> validate_birth_date_in_the_past()

    refute changeset.valid?
    assert ["must be in the past"] == errors_on(changeset).birth_date
  end

  test "making the custom validation reusable for other date fields" do
    params = %{"name" => "Thelonius Monk", "birth_date" => "2117-10-10"}

    changeset =
      %Artist{}
      |> cast(params, [:name, :birth_date])
      |> validate_in_the_past(:birth_date)

    refute changeset.valid?
    assert ["must be in the past"] == errors_on(changeset).birth_date
  end

  defp validate_birth_date_in_the_past(changeset) do
    validate_change(changeset, :birth_date, fn :birth_date, birth_date ->
      cond do
        is_nil(birth_date) -> []
        Date.compare(birth_date, Date.utc_today()) == :lt -> []
        true -> [birth_date: "must be in the past"]
      end
    end)
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
