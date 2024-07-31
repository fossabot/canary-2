import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  build: {
    minify: "terser",
    terserOptions: {
      format: {
        comments: /webpackIgnore|@vite/,
      },
    },
    lib: {
      entry: [
        ...["index", "canary-root"],
        ...[
          "canary-provider-mock",
          "canary-provider-cloud",
          "canary-provider-pagefind",
          "canary-provider-vitepress-minisearch",
        ],
        ...[
          "canary-callout",
          "canary-callout-cal",
          "canary-callout-calendly",
          "canary-callout-slack",
          "canary-callout-discord",
        ],
        "canary-modal",
        "canary-content",
        ...["canary-trigger-searchbar", "canary-trigger-logo"],
        ...[
          "canary-search",
          "canary-search-input",
          "canary-search-results",
          "canary-search-results-tabs",
        ],
        ...["canary-ask", "canary-ask-input", "canary-ask-results"],
        ...[
          "canary-feedback",
          "canary-feedback-text",
          "canary-feedback-textarea",
        ],
        ...["canary-reference", "canary-tooltip", "canary-footer"],
        ...[
          "contexts",
          "controllers",
          "mixins",
          "types/index",
          "types/pagefind",
        ],
      ].reduce(
        (acc, cur) => ({ ...acc, [cur]: resolve(__dirname, `src/${cur}.ts`) }),
        {} as Record<string, string>,
      ),
      formats: ["es"],
      fileName: (_, entryName) => `${entryName}.js`,
    },
    outDir: "components",
    rollupOptions: {
      external: ["@localSearchIndex", "minisearch"],
    },
  },
});
