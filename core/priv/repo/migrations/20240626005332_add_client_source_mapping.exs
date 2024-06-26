defmodule Canary.Repo.Migrations.AddClientSourceMapping do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:client_sources, primary_key: false) do
      add :client_id,
          references(:clients,
            column: :id,
            name: "client_sources_client_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false

      add :source_id,
          references(:sources,
            column: :id,
            name: "client_sources_source_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false
    end
  end

  def down do
    drop constraint(:client_sources, "client_sources_client_id_fkey")

    drop constraint(:client_sources, "client_sources_source_id_fkey")

    drop table(:client_sources)
  end
end