import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

import "./canary-hero-icon";

@customElement("canary-trigger")
export class CanaryTrigger extends LitElement {
  render() {
    return html`
      <button>
        <canary-hero-icon name="magnifying-glass"></canary-hero-icon>
        <span>Search</span>

        <kbd>
          <kbd>⌘</kbd>
          <kbd>K</kbd>
        </kbd>
      </button>
    `;
  }

  static styles = css`
    button {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      border: 0;
      background-color: transparent;
      color: var(--canary-color-gray-1);
      cursor: pointer;
      height: 2.5rem;
      font-size: 1.25rem;
    }

    @media (min-width: 50rem) {
      button {
        border: 1px solid var(--canary-color-gray-5);
        border-radius: 0.5rem;
        padding-inline-start: 0.75rem;
        padding-inline-end: 0.5rem;
        background-color: var(--canary-color-black);
        color: var(--canary-color-gray-2);
        font-size: 0.875rem;
        width: 100%;
        max-width: 22rem;
      }
      button:hover {
        border-color: var(--canary-color-gray-2);
        color: var(--canary-color-white);
      }

      button > :last-child {
        margin-inline-start: auto;
      }
    }

    button > kbd {
      display: none;
      border-radius: 0.25rem;
      font-size: 0.75rem;
      gap: 0.25em;
      padding-inline: 0.375rem;
      background-color: var(--canary-color-gray-6);
    }

    kbd {
      font-family: var(--canary-font);
    }

    span {
      display: none;
    }

    @media (min-width: 50rem) {
      span {
        display: inline;
      }

      button > kbd {
        display: flex;
      }
    }
  `;
}
