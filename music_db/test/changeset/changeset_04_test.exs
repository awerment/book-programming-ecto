defmodule Changeset04Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.Artist

  describe "working with changeset validations" do
    test "valid changeset" do
      params = %{"name" => "Thelonius Monk", "birth_date" => "1917-10-10"}

      changeset =
        %Artist{}
        |> cast(params, [:name, :birth_date])
        |> validate_required([:name, :birth_date])
        |> validate_length(:name, min: 3)

      assert changeset.valid?
    end

    test "invalid changeset" do
      params = %{"name" => "Thelonius Monk"}

      changeset =
        %Artist{}
        |> cast(params, [:name, :birth_date])
        |> validate_required([:name, :birth_date])
        |> validate_length(:name, min: 3)

      refute changeset.valid?
      assert ["can't be blank"] == errors_on(changeset).birth_date
    end

    test "validations are always run, errors are collected" do
      params = %{"name" => "x"}

      changeset =
        %Artist{}
        |> cast(params, [:name, :birth_date])
        |> validate_required([:name, :birth_date])
        |> validate_length(:name, min: 3)

      refute changeset.valid?
      assert ["should be at least 3 character(s)"] == errors_on(changeset).name
      assert ["can't be blank"] == errors_on(changeset).birth_date
    end
  end
end
