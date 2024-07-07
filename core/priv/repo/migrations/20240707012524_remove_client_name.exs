defmodule Canary.Repo.Migrations.RemoveClientName do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:clients) do
      remove :name
      modify :source_id, :uuid, null: false
    end

    drop_if_exists unique_index(:clients, [:source_id, :name],
                     name: "clients_unique_client_index"
                   )

    drop_if_exists unique_index(:clients, [:discord_server_id, :discord_channel_id],
                     name: "clients_unique_discord_index"
                   )

    create unique_index(:clients, [:source_id, :type], name: "clients_unique_client_index")
  end

  def down do
    drop_if_exists unique_index(:clients, [:source_id, :type],
                     name: "clients_unique_client_index"
                   )

    create unique_index(:clients, [:discord_server_id, :discord_channel_id],
             name: "clients_unique_discord_index"
           )

    create unique_index(:clients, [:source_id, :name], name: "clients_unique_client_index")

    alter table(:clients) do
      modify :source_id, :uuid, null: true
      add :name, :text, null: false
    end
  end
end