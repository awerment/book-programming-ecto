defmodule Changeset01Test do
  use MusicDB.DataCase, async: true
  import ExUnit.CaptureIO
  alias MusicDB.Artist

  defp insert_artist(params) do
    %Artist{}
    |> cast(params, [:name])
    |> validate_required([:name])
    |> Repo.insert()
    |> case do
      {:ok, artist} -> IO.puts("Record for #{artist.name} was created.")
      {:error, changeset} -> IO.inspect(changeset.errors)
    end
  end

  test "successful insert with changeset (valid data)" do
    {_, output} =
      with_io(fn ->
        insert_artist(%{name: "Gene Harris"})
      end)

    assert "Record for Gene Harris was created.\n" == output
  end

  test "failed insert with changeset (invalid data)" do
    {_, output} =
      with_io(fn ->
        insert_artist(%{some_key: "unknown"})
      end)

    assert ~S([name: {"can't be blank", [validation: :required]}]\n) == output
  end
end
