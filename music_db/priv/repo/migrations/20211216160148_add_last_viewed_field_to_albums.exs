defmodule MusicDB.Repo.Migrations.AddLastViewedFieldToAlbums do
  use Ecto.Migration

  def change do
    alter table("albums") do
      add :last_viewed, :utc_datetime
    end
  end
end
