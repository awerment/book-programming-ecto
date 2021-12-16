defmodule Changeset06Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.Genre

  describe "working with constraints" do
    test "case: inserting a genre with the same name causes an error (unique constraint set on DB)" do
      assert {:ok, _record} = Repo.insert(%Genre{name: "speed polka"})

      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert(%Genre{name: "speed polka"})
      end
    end

    test "using unique_constraint to convert the exception into a changeset error" do
      Repo.insert!(%Genre{name: "bebop"})

      params = %{"name" => "bebop"}

      changeset =
        %Genre{}
        |> cast(params, [:name])
        |> validate_required([:name])
        |> validate_length(:name, min: 3)
        |> unique_constraint(:name)

      # constraints are not checked immediately...
      assert changeset.valid?
      assert [] == changeset.errors

      # ... only when we actually hit the database
      assert {:error, changeset} = Repo.insert(changeset)
      refute changeset.valid?
      assert ["has already been taken"] == errors_on(changeset).name
    end

    test "if validation errors are present on the changeset, constraints are not run at all" do
      Repo.insert!(%Genre{name: "pop"})

      params = %{"name" => "pop"}

      result =
        %Genre{}
        |> cast(params, [:name])
        |> validate_required([:name])
        |> validate_length(:name, min: 5)
        |> unique_constraint(:name)
        |> Repo.insert()

      assert {:error, changeset} = result
      refute changeset.valid?
      # note that the "has already been taken" error is not present
      # the constraint was never checked, because the name validation failed
      assert ["should be at least 5 character(s)"] == errors_on(changeset).name
    end

    test "to check the unique constraint immediately along with the validations, use unsafe_validate_unique" do
      Repo.insert!(%Genre{name: "pop"})

      params = %{"name" => "pop"}

      changeset =
        %Genre{}
        |> cast(params, [:name])
        |> validate_required([:name])
        # needs to be called before other validations on the same field
        |> unsafe_validate_unique(:name, Repo)
        |> validate_length(:name, min: 5)

      refute changeset.valid?

      assert ["should be at least 5 character(s)", "has already been taken"] ==
               errors_on(changeset).name
    end
  end
end
