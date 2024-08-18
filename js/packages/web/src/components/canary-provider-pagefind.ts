import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import type {
  BeforeSearchFunction,
  SearchFunction,
  SearchReference,
  PagefindResult,
} from "../types";

import { createEvent } from "../store";
import { stripURL } from "../utils";
import { wrapper } from "../styles";
import { cache } from "../decorators";

const NAME = "canary-provider-pagefind";

type Options = {
  path?: string;
  styles?: Record<string, string>;
  pagefind?: { ranking: Record<string, number> };
  _base?: string;
  _replace?: string;
};

@customElement(NAME)
export class CanaryProviderPagefind extends LitElement {
  @property({ type: Object })
  options: Options = {};

  @state()
  private _pagefind: any | null = null;

  @property({ type: Number, attribute: "max-pages" })
  maxPages = 30;

  @property({ type: Number, attribute: "max-sub-results" })
  maxSubResults = 5;

  async connectedCallback() {
    super.connectedCallback();

    const pagefind = await this._importPagefind();
    this._initPagefind(pagefind);

    this.dispatchEvent(
      createEvent({
        type: "register_operations",
        data: {
          search: cache(this.search),
          beforeSearch: this.beforeSearch,
        },
      }),
    );
  }

  private async _importPagefind() {
    try {
      return import(
        /* @vite-ignore */
        /* webpackIgnore: true */
        this.options?.path ?? "/pagefind/pagefind.js"
      );
    } catch (e) {
      throw new Error(`Failed to import pagefind': ${e}`);
    }
  }

  private async _initPagefind(pagefind: any) {
    try {
      pagefind.init();
      if (this.options.pagefind) {
        await pagefind.options(this.options.pagefind);
      }
      this._pagefind = pagefind;
    } catch (e) {
      throw new Error(`Failed to initialize pagefind': ${e}`);
    }
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  beforeSearch: BeforeSearchFunction = async (query) => {
    this._pagefind.preload(query);
  };

  search: SearchFunction = async (query, signal) => {
    const { results } = await this._pagefind.search(query);
    signal.throwIfAborted();

    const search = await Promise.all(
      results.slice(0, this.maxPages).map((r: any) => r.data()),
    ).then((results: PagefindResult[]) => this._transform(results));

    return { search };
  };

  private _transform(results: PagefindResult[]): SearchReference[] {
    const subResults = results.flatMap((result) => {
      return result.sub_results.map((subResult) => ({
        ...subResult,
        meta: result.meta,
      }));
    });

    const getBestScore = (subResult: (typeof subResults)[0]) =>
      subResult.weighted_locations.reduce(
        (acc, cur) => Math.max(acc, cur.balanced_score),
        -1,
      );

    const getTitles = (subResult: (typeof subResults)[0]) => {
      return subResult.meta.title === subResult.title
        ? []
        : [subResult.meta.title];
    };

    const transformURL = (url: string) => {
      return this.options._base
        ? this.options._base +
            stripURL(url.replace(this.options._replace || "", ""))
        : url;
    };

    return subResults
      .sort((a, b) => getBestScore(b) - getBestScore(a))
      .slice(0, this.maxSubResults)
      .map((result) => {
        const ref: SearchReference = {
          url: transformURL(result.url),
          title: result.title,
          titles: getTitles(result),
          excerpt: result.excerpt,
        };

        return ref;
      })
      .slice(0, this.maxPages);
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderPagefind;
  }
}
