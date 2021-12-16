defmodule Changeset10Test do
  use MusicDB.DataCase, async: true
  alias MusicDB.{Album, Artist}

  describe "associations with internal data and put_assoc" do
    test "trying to put an associated records into an un-preloaded collection raises" do
      assert_raise RuntimeError, fn ->
        Repo.get_by(Artist, name: "Miles Davis")
        |> change()
        |> put_assoc(:albums, [%Album{title: "Miles Ahead"}])
        |> Repo.update()
      end
    end

    test "trying to put an association with on_replace: :raise, well... raises as well" do
      assert_raise RuntimeError, fn ->
        Repo.get_by(Artist, name: "Miles Davis")
        |> Repo.preload(:albums)
        |> change()
        |> put_assoc(:albums, [%Album{title: "Miles Ahead"}])
        |> Repo.update()
      end

      # explanation: put_assoc tries to _replace_ the entire :albums collection on the artist
      # for that to work, Ecto needs to know what to do with the collection's current records
    end

    test "the (convoluted, but) right way of adding a new album to an existing artist with put_assoc" do
      artist = Repo.get_by(Artist, name: "Miles Davis") |> Repo.preload(:albums)

      {:ok, artist} =
        artist
        |> change()
        |> put_assoc(:albums, [%Album{title: "Miles Ahead"} | artist.albums])
        |> Repo.update()

      assert "Miles Ahead" in Enum.map(artist.albums, & &1.title)
    end

    test "inserting new artist along with an album with put_assoc, using an Album schema struct" do
      {:ok, artist} =
        %Artist{name: "Eliane Elias"}
        |> change()
        |> put_assoc(:albums, [%Album{title: "Made In Brazil"}])
        |> Repo.insert()

      assert "Made In Brazil" in Enum.map(artist.albums, & &1.title)
    end

    test "inserting new artist along with an album with put_assoc, using a map" do
      {:ok, artist} =
        %Artist{name: "Eliane Elias"}
        |> change()
        |> put_assoc(:albums, [%{title: "Made In Brazil"}])
        |> Repo.insert()

      assert "Made In Brazil" in Enum.map(artist.albums, & &1.title)
    end

    test "inserting new artist along with an album with put_assoc, using a keyword list" do
      {:ok, artist} =
        %Artist{name: "Eliane Elias"}
        |> change()
        |> put_assoc(:albums, [[title: "Made In Brazil"]])
        |> Repo.insert()

      assert "Made In Brazil" in Enum.map(artist.albums, & &1.title)
    end
  end
end
