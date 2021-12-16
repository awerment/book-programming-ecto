defmodule Changeset11Test do
  use MusicDB.DataCase, async: true

  describe "using associations with external data" do
    # define minimal schema modules for the examples
    defmodule Album1 do
      use Ecto.Schema

      schema "albums" do
        field(:title, :string)
        belongs_to(:artist, Changeset11Test.Artist1)
      end
    end

    defmodule Artist1 do
      use Ecto.Schema

      schema "artists" do
        field(:name, :string)
        has_many(:albums, Changeset11Test.Album1)
      end
    end

    test "(failing to) create a new artist with associated albums from a single params map" do
      params = %{"name" => "Esperanza Spaling", "albums" => [%{"title" => "Junjo"}]}

      # cas_assoc(:albums) looks for the Album.__changeset__/0 function
      assert_raise UndefinedFunctionError, fn ->
        %Artist1{}
        |> cast(params, [:name])
        |> cast_assoc(:albums)
      end
    end

    # re-define the album schema with a changeset function
    defmodule Album2 do
      use Ecto.Schema

      schema "albums" do
        field(:title, :string)
        belongs_to(:artist, Changeset11Test.Artist2)

        def changeset(album, params) do
          album
          |> cast(params, [:title])
          |> validate_required([:title])
        end
      end
    end

    defmodule Artist2 do
      use Ecto.Schema

      schema "artists" do
        field(:name, :string)
        has_many(:albums, Changeset11Test.Album2)
      end
    end

    test "create a new artist with associated albums from a single params map" do
      # re-define the album schema with a changeset function
      params = %{"name" => "Esperanza Spaling", "albums" => [%{"title" => "Junjo"}]}

      changeset =
        %Artist2{}
        |> cast(params, [:name])
        |> cast_assoc(:albums)

      assert changeset.changes.name
      assert changeset.changes.albums
      # the :albums field in the changes is actually a nested changeset itself
      [%Ecto.Changeset{} = album_changeset] = changeset.changes.albums
      assert album_changeset.changes.title
    end

    test "overriding the changeset function that cast_assoc looks for" do
      params = %{"name" => "Esperanza Spaling", "albums" => [%{"title" => "Junjo"}]}

      changeset =
        %Artist1{}
        |> cast(params, [:name])
        |> cast_assoc(:albums, with: &Changeset11Test.album_changeset/2)

      assert changeset.changes.name
      assert changeset.changes.albums
      # the :albums field in the changes is actually a nested changeset itself
      [%Ecto.Changeset{} = album_changeset] = changeset.changes.albums
      assert album_changeset.changes.title
    end

    def album_changeset(album, params) do
      album
      |> cast(params, [:title])
      |> validate_required([:title])
    end

    # redefine Artist schema with :on_replace option
    defmodule Artist3 do
      use Ecto.Schema

      schema "artists" do
        field(:name, :string)
        has_many(:albums, Changeset11Test.Album3, foreign_key: :artist_id, on_replace: :nilify)
      end
    end

    defmodule Album3 do
      use Ecto.Schema

      schema "albums" do
        field(:title, :string)
        timestamps()
        belongs_to(:artist, Changeset11Test.Artist3, foreign_key: :artist_id)
      end

      def changeset(album, params) do
        album
        |> cast(params, [:title])
        |> validate_required([:title])
      end
    end

    test "updating records with associations" do
      artist = Repo.get_by(Artist3, name: "Bill Evans") |> Repo.preload(:albums)
      assert 2 == length(artist.albums)

      portrait = Repo.get_by(Album3, title: "Portrait In Jazz")
      kind_of_blue = Repo.get_by(Album3, title: "Kind Of Blue")

      params = %{
        "albums" => [
          # new album -> :insert
          %{"title" => "Explorations"},
          # changed album -> :update
          %{"title" => "Portrait In Jazz (remastered)", "id" => portrait.id},
          # existing album associated with another artist -> :insert, id will be ignored
          %{"title" => "Kind Of Blue", "id" => kind_of_blue.id}
          # not listed: second album for Bill Evans, its :artist_id field will be set to null
        ]
      }

      assert {:ok, artist} =
               artist
               |> cast(params, [])
               |> cast_assoc(:albums)
               |> Repo.update()

      album_titles = artist.albums |> Enum.map(& &1.title)

      assert MapSet.new(album_titles) ==
               MapSet.new(["Explorations", "Portrait In Jazz (remastered)", "Kind Of Blue"])

      # confirm that there are now two different "Kind Of Blue" album records
      assert 2 == Repo.aggregate(from(a in Album3, where: a.title == "Kind Of Blue"), :count)

      # confirm that "You Must Believe In Spring" is still present, but not associated with Bill Evans
      ymbis = Repo.one(from(a in Album3, where: a.title == "You Must Believe In Spring"))
      refute ymbis.artist_id
    end
  end
end
