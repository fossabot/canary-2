defmodule Canary.Index do
  alias Canary.Sources.Source
  alias Canary.Sources.Webpage
  alias Canary.Sources.GithubIssue
  alias Canary.Sources.GithubDiscussion

  alias Canary.Index.Client
  alias Canary.Index.Document

  def insert_document(%Webpage.Chunk{} = chunk) do
    meta = %Document.Webpage.Meta{
      url: chunk.url,
      document_id: chunk.document_id,
      is_parent: chunk.is_parent
    }

    doc = %Document.Webpage{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title || "",
      content: chunk.content || "",
      tags: [],
      meta: meta
    }

    Client.index_document(:webpage, doc)
  end

  def insert_document(%GithubIssue.Chunk{} = chunk) do
    meta = %Document.GithubIssue.Meta{
      url: chunk.url,
      document_id: chunk.document_id,
      is_parent: chunk.is_parent
    }

    doc = %Document.GithubIssue{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title || "",
      content: chunk.content || "",
      tags: [],
      meta: meta
    }

    Client.index_document(:github_issue, doc)
  end

  def insert_document(%GithubDiscussion.Chunk{} = chunk) do
    meta = %Document.GithubDiscussion.Meta{
      url: chunk.url,
      document_id: chunk.document_id,
      is_parent: chunk.is_parent
    }

    doc = %Document.GithubDiscussion{
      id: chunk.index_id,
      source_id: chunk.source_id,
      title: chunk.title || "",
      content: chunk.content || "",
      tags: [],
      meta: meta
    }

    Client.index_document(:github_discussion, doc)
  end

  def delete_document(source_type, id)
      when source_type in [
             :webpage,
             :github_issue,
             :github_discussion
           ] do
    Client.delete_document(source_type, id)
  end

  def search(sources, queries, opts \\ []) when is_list(queries) do
    args = build_args(sources, queries, opts)

    case Canary.Index.Client.multi_search(args) do
      {:ok, %Req.Response{status: 200, body: %{"results" => results}}} ->
        ret =
          results
          |> Enum.reject(fn %{"hits" => hits} -> length(hits) == 0 end)
          |> Enum.map(fn %{"hits" => hits} ->
            hits =
              hits
              |> Enum.map(&transform_hit/1)
              |> Enum.uniq_by(& &1.id)

            source_id = hits |> Enum.at(0) |> Map.get(:source_id)

            %{source_id: source_id, hits: hits}
          end)

        {:ok, ret}

      {:ok, res} ->
        {:error, res}

      {:error, error} ->
        {:error, error}
    end
  end

  defp build_args(sources, queries, opts) do
    tags = opts[:tags]

    for(source <- sources, query <- queries, do: {source, query})
    |> Enum.map(fn {%Source{id: source_id, config: %Ash.Union{type: type}}, query} ->
      filter_by =
        [
          "source_id:=[#{source_id}]",
          if(tags != nil and tags != []) do
            "tags:=[#{Enum.join(tags, ",")}]"
          end
        ]
        |> Enum.reject(&is_nil/1)
        |> Enum.join(" && ")

      query_by = ["title", "content"] |> Enum.join(",")
      query_by_weights = [3, 1] |> Enum.join(",")

      %{
        collection: to_string(type),
        q: query,
        prefix: true,
        query_by: query_by,
        query_by_weights: query_by_weights,
        filter_by: filter_by,
        sort_by: "_text_match:desc",
        highlight_fields: "content",
        stopwords: Canary.Index.Stopword.id(),
        prioritize_exact_match: true,
        prioritize_token_position: false,
        prioritize_num_matching_fields: false,
        max_candidates: 4 * 4
      }
      |> add_embedding_args(opts)
    end)
  end

  defp add_embedding_args(args, opts) do
    embedding = opts[:embedding]
    embedding_alpha = opts[:embedding_alpha] || 0.3

    if embedding do
      args
      |> Map.put(
        :vector_query,
        "embedding:([#{Enum.join(embedding, ",")}], alpha: #{embedding_alpha})"
      )
    else
      args
    end
  end

  defp transform_hit(hit) do
    %{
      id: hit["document"]["id"],
      document_id: hit["document"]["meta"]["document_id"],
      source_id: hit["document"]["source_id"],
      url: hit["document"]["meta"]["url"],
      title: hit["document"]["title"],
      excerpt: hit["highlight"]["content"]["snippet"] || hit["document"]["content"],
      tags: hit["document"]["tags"],
      is_parent: hit["document"]["meta"]["is_parent"]
    }
  end
end
