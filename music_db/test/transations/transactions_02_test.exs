defmodule Transactions02Test do
  use MusicDB.DataCase, async: true
  import ExUnit.CaptureIO
  alias MusicDB.{Artist, Log}

  test "tx rollbacks are only triggered on raised errors, no on {:error, _} returns" do
    changeset =
      %Artist{name: nil}
      |> change()
      |> validate_required([:name])

    {_result, io} =
      with_io(fn ->
        Repo.transaction(fn ->
          case Repo.insert(changeset) do
            {:ok, _artist} -> IO.puts("Artist insert succeeded")
            {:error, _cs} -> IO.puts("Artist insert failed")
          end

          case Repo.insert(Log.changeset_for_insert(changeset)) do
            {:ok, _log} -> IO.puts("Log insert succeeded")
            {:error, _cs} -> IO.puts("Log insert failed")
          end
        end)
      end)

    assert "Artist insert failed\nLog insert succeeded\n" == io
  end

  test "use Repo.rollback/1 to manually trigger a rollback in a transaction " do
    changeset =
      %Artist{name: nil}
      |> change()
      |> validate_required([:name])

    {result, io} =
      with_io(fn ->
        Repo.transaction(fn ->
          case Repo.insert(changeset) do
            {:ok, _artist} -> IO.puts("Artist insert succeeded")
            {:error, _cs} -> Repo.rollback("Artist insert failed")
          end

          case Repo.insert(Log.changeset_for_insert(changeset)) do
            {:ok, _log} -> IO.puts("Log insert succeeded")
            {:error, _cs} -> Repo.rollback("Log insert failed")
          end
        end)
      end)

    assert "" == io
    assert {:error, "Artist insert failed"} == result
  end
end
