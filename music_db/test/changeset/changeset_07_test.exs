defmodule Changeset07Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.Artist
  import ExUnit.CaptureIO

  test "reminder: typical successful params > changeset > insert workflow" do
    params = %{"name" => "Gene Harris"}

    changeset =
      %Artist{}
      |> cast(params, [:name])
      |> validate_required([:name])

    {changeset_or_record, io} =
      with_io(fn ->
        case Repo.insert(changeset) do
          {:ok, artist} ->
            IO.puts("Record for #{artist.name} was created.")
            artist

          {:error, changeset} ->
            IO.inspect(changeset.errors)
            changeset
        end
      end)

    assert %Artist{} = changeset_or_record
    assert "Record for Gene Harris was created.\n" == io
  end

  test "reminder: typical failed params > changeset > insert workflow" do
    params = %{"name" => nil}

    changeset =
      %Artist{}
      |> cast(params, [:name])
      |> validate_required([:name])

    {changeset_or_record, io} =
      with_io(fn ->
        # it is safe to try to insert/update with a changeset that contains errors
        # the repo will return a new changeset with the validation and any additional errors
        case Repo.insert(changeset) do
          {:ok, artist} ->
            IO.puts("Record for #{artist.name} was created.")
            artist

          {:error, changeset} ->
            IO.inspect(errors_on(changeset).name)
            changeset
        end
      end)

    assert %Ecto.Changeset{} = changeset_or_record
    assert ~s(["can't be blank"]\n) == io
  end
end
