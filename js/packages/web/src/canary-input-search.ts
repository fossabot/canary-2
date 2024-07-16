import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { consume } from "@lit/context";
import {
  defaultModeContext,
  ModeContext,
  modeContext,
  queryContext,
} from "./contexts";

import { input } from "./styles";
import "./canary-hero-icon";

@customElement("canary-input-search")
export class CanaryInputSearch extends LitElement {
  @consume({ context: queryContext, subscribe: true })
  @property({ reflect: true })
  value = "";

  @consume({ context: modeContext, subscribe: true })
  @property({ attribute: false })
  mode: ModeContext = defaultModeContext;

  render() {
    return html`
      <style>
        :host {
          flex-grow: ${this.mode.current === "Ask" ? "0" : "1"};
          display: ${this.mode.current === "Ask" ? "none" : "block"};
        }
      </style>

      <div class="container">
        <canary-hero-icon name="magnifying-glass"></canary-hero-icon>
        <input
          type="text"
          value=${this.value}
          autocomplete="off"
          placeholder="Search for anything..."
          @input=${this._handleInput}
          @keydown=${this._handleKeyDown}
          autofocus
          onfocus="this.setSelectionRange(this.value.length,this.value.length);"
        />
      </div>
    `;
  }

  static styles = input;

  private _handleInput(e: KeyboardEvent) {
    const input = e.target as HTMLInputElement;
    const event = new CustomEvent("change", {
      detail: input.value,
      bubbles: true,
      composed: true,
    });
    this.dispatchEvent(event);
  }

  private _handleKeyDown(e: KeyboardEvent) {
    if (e.key === "Tab") {
      e.preventDefault();
      const event = new CustomEvent("tab", { bubbles: true, composed: true });
      this.dispatchEvent(event);
    }
  }
}
