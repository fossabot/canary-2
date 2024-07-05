defmodule Canary.Repo.Migrations.AddResources do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :text, null: false
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")

    create table(:user_identities, primary_key: false) do
      add :refresh_token, :text
      add :access_token_expires_at, :utc_datetime_usec
      add :access_token, :text
      add :uid, :text, null: false
      add :strategy, :text, null: false
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :user_id,
          references(:users,
            column: :id,
            name: "user_identities_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:user_identities, [:strategy, :uid, :user_id],
             name: "user_identities_unique_on_strategy_and_uid_and_user_id_index"
           )

    create table(:usages, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :generation, :bigint, default: 0
      add :account_id, :uuid
    end

    create table(:tokens, primary_key: false) do
      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :extra_data, :map
      add :purpose, :text, null: false
      add :expires_at, :utc_datetime, null: false
      add :subject, :text, null: false
      add :jti, :text, null: false, primary_key: true
    end

    create table(:sources, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :type, :text, null: false
      add :base_url, :text, null: false
      add :base_path, :text, null: false
      add :account_id, :uuid
    end

    create table(:sessions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :type, :text, null: false
      add :client_session_id, :bigint, null: false
      add :account_id, :uuid
    end

    create table(:messages, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :session_id,
          references(:sessions,
            column: :id,
            name: "messages_session_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :role, :text, null: false
      add :content, :text, null: false
    end

    create table(:github_repos, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :full_name, :text, null: false
      add :app_id, :uuid
      add :source_id, :uuid
    end

    create table(:github_apps, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:github_repos) do
      modify :app_id,
             references(:github_apps,
               column: :id,
               name: "github_repos_app_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )

      modify :source_id,
             references(:sources,
               column: :id,
               name: "github_repos_source_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    create unique_index(:github_repos, [:app_id, :full_name],
             name: "github_repos_unique_repo_index"
           )

    alter table(:github_apps) do
      add :installation_id, :bigint, null: false
      add :account_id, :uuid
    end

    create table(:feedbacks, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :account_id, :uuid
    end

    create table(:documents, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :absolute_path, :text
      add :content_hash, :binary, null: false

      add :source_id,
          references(:sources,
            column: :id,
            name: "documents_source_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          )
    end

    create unique_index(:documents, [:content_hash], name: "documents_unique_content_index")

    create table(:clients, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :name, :text, null: false
      add :type, :text, null: false
      add :discord_server_id, :bigint
      add :discord_channel_id, :bigint

      add :source_id,
          references(:sources,
            column: :id,
            name: "clients_source_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          )
    end

    create unique_index(:clients, [:source_id, :name], name: "clients_unique_client_index")

    create unique_index(:clients, [:discord_server_id, :discord_channel_id],
             name: "clients_unique_discord_index"
           )

    create table(:chunks, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :content, :text, null: false
      add :embedding, :vector, null: false, size: 384
      add :url, :text

      add :document_id,
          references(:documents,
            column: :id,
            name: "chunks_document_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          )
    end

    create table(:billings, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :stripe_customer, :map
      add :stripe_subscription, :map
      add :account_id, :uuid
    end

    create table(:accounts, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:usages) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "usages_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:sources) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "sources_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:sessions) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "sessions_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    create unique_index(:sessions, [:account_id, :type, :client_session_id],
             name: "sessions_unique_session_index"
           )

    alter table(:github_apps) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "github_apps_account_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end

    alter table(:feedbacks) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "feedbacks_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:billings) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "billings_account_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :nothing
             )
    end

    alter table(:accounts) do
      add :name, :text, null: false
    end

    create table(:account_users, primary_key: false) do
      add :user_id,
          references(:users,
            column: :id,
            name: "account_users_user_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false

      add :account_id,
          references(:accounts,
            column: :id,
            name: "account_users_account_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false
    end
  end

  def down do
    drop constraint(:account_users, "account_users_user_id_fkey")

    drop constraint(:account_users, "account_users_account_id_fkey")

    drop table(:account_users)

    alter table(:accounts) do
      remove :name
    end

    drop constraint(:billings, "billings_account_id_fkey")

    alter table(:billings) do
      modify :account_id, :uuid
    end

    drop constraint(:feedbacks, "feedbacks_account_id_fkey")

    alter table(:feedbacks) do
      modify :account_id, :uuid
    end

    drop constraint(:github_apps, "github_apps_account_id_fkey")

    alter table(:github_apps) do
      modify :account_id, :uuid
    end

    drop_if_exists unique_index(:sessions, [:account_id, :type, :client_session_id],
                     name: "sessions_unique_session_index"
                   )

    drop constraint(:sessions, "sessions_account_id_fkey")

    alter table(:sessions) do
      modify :account_id, :uuid
    end

    drop constraint(:sources, "sources_account_id_fkey")

    alter table(:sources) do
      modify :account_id, :uuid
    end

    drop constraint(:usages, "usages_account_id_fkey")

    alter table(:usages) do
      modify :account_id, :uuid
    end

    drop table(:accounts)

    drop table(:billings)

    drop constraint(:chunks, "chunks_document_id_fkey")

    drop table(:chunks)

    drop_if_exists unique_index(:clients, [:discord_server_id, :discord_channel_id],
                     name: "clients_unique_discord_index"
                   )

    drop_if_exists unique_index(:clients, [:source_id, :name],
                     name: "clients_unique_client_index"
                   )

    drop constraint(:clients, "clients_source_id_fkey")

    drop table(:clients)

    drop_if_exists unique_index(:documents, [:content_hash],
                     name: "documents_unique_content_index"
                   )

    drop constraint(:documents, "documents_source_id_fkey")

    drop table(:documents)

    drop table(:feedbacks)

    alter table(:github_apps) do
      remove :account_id
      remove :installation_id
    end

    drop_if_exists unique_index(:github_repos, [:app_id, :full_name],
                     name: "github_repos_unique_repo_index"
                   )

    drop constraint(:github_repos, "github_repos_app_id_fkey")

    drop constraint(:github_repos, "github_repos_source_id_fkey")

    alter table(:github_repos) do
      modify :source_id, :uuid
      modify :app_id, :uuid
    end

    drop table(:github_apps)

    drop table(:github_repos)

    drop constraint(:messages, "messages_session_id_fkey")

    drop table(:messages)

    drop table(:sessions)

    drop table(:sources)

    drop table(:tokens)

    drop table(:usages)

    drop_if_exists unique_index(:user_identities, [:strategy, :uid, :user_id],
                     name: "user_identities_unique_on_strategy_and_uid_and_user_id_index"
                   )

    drop constraint(:user_identities, "user_identities_user_id_fkey")

    drop table(:user_identities)

    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)
  end
end
