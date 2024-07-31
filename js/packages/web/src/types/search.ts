export interface SearchReference {
  url: string;
  title: string;
  titles?: string[];
  tags?: string[];
  excerpt?: string;
}

export type SearchFunction = (
  query: string,
  signal?: AbortSignal,
) => Promise<SearchReference[] | null>;

export type BeforeSearchFunction = (query: string) => Promise<any>;
