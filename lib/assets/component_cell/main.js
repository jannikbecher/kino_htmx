export function init(ctx, payload) {
  ctx.importCSS("main.css");

  ctx.root.innerHTML = `
  <input type="text" id="component-type"></input>
  <input type="text" id="component-path"></input>
  <textarea id="html"></textarea>
  `;

  const componentTypeEl = ctx.root.querySelector("#component-type");
  componentTypeEl.value = payload.type;
  componentTypeEl.addEventListener("change", (event) => {
    ctx.pushEvent("update", { type: event.target.value });
  });

  const componentPathEl = ctx.root.querySelector("#component-path");
  componentPathEl.value = payload.path;
  componentPathEl.addEventListener("change", (event) => {
    ctx.pushEvent("update", { path: event.target.value });
  });

  const textarea = ctx.root.querySelector("#html");
  textarea.value = payload.html;
  textarea.addEventListener("change", (event) => {
    ctx.pushEvent("update", { html: event.target.value });
  });

  ctx.handleEvent("update", ({ type, path, html }) => {
    componentTypeEl.value = type;
    componentPathEl.value = path;
    textarea.value = html;
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change"));
  });
}
