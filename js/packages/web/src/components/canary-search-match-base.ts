import { LitElement, html, css } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";

import { global } from "../styles";
import { MODAL_CLOSE_EVENT } from "./canary-modal";

const NAME = "canary-search-match-base";

/**
 * @csspart container - Container of the match
 *
 * @slot content-before - Content before the match
 * @slot url - URL of the match
 * @slot title-icon - Icon for the title
 * @slot title - Title of the match
 * @slot title-badge - Badge displayed next to the title
 * @slot excerpt - Excerpt of the match
 * @slot sub-results - Sub-results related to the match
 */
@registerCustomElement(NAME)
export class CanarySearchMatchBase extends LitElement {
  @property({ type: String })
  url!: string;

  render() {
    return html`
      <button class="container" part="container" @click=${this._handleClick}>
        <slot name="content-before"></slot>
        <div class="content">
          <slot name="url"></slot>
          <div class="title">
            <slot name="title-icon"></slot>
            <slot name="title"></slot>
            <slot name="title-badge"></slot>
          </div>
          <slot name="excerpt"></slot>
          <slot name="sub-results"></slot>
        </div>
        <div class="arrow">
          <div class="i-heroicons-chevron-right"></div>
        </div>
      </button>
    `;
  }

  private _handleClick(e: MouseEvent) {
    e.stopPropagation();

    if (e.metaKey || e.ctrlKey) {
      window.open(this.url, "_blank");
      return;
    }

    this.dispatchEvent(
      new CustomEvent(MODAL_CLOSE_EVENT, { bubbles: true, composed: true }),
    );
    window.location.href = this.url;
  }

  static styles = [
    global,
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        cursor: pointer;
        width: 100%;

        position: relative;
        cursor: pointer;

        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 4px;

        width: 100%;
        padding: 6px 9px;
        border: 1px solid var(--canary-color-gray-90);
        border-radius: 8px;
        background-color: var(--canary-is-light, var(--canary-color-gray-95))
          var(--canary-is-dark, var(--canary-color-gray-80));
      }

      .container:hover {
        background-color: var(--canary-is-light, var(--canary-color-primary-95))
          var(--canary-is-dark, var(--canary-color-primary-70));
      }

      .container:hover .arrow {
        opacity: 0.5;
      }

      .arrow {
        position: absolute;
        top: 45%;
        right: 8px;
        opacity: 0;
      }

      .content {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;

        overflow: hidden;
        text-overflow: ellipsis;
      }

      .title {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 8px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchMatchBase;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
