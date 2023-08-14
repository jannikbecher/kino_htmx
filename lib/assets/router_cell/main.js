export function init(ctx, payload) {
  ctx.importCSS("main.css");

  ctx.root.innerHTML = `
  <input type="text" id="router-port"></input>
  <textarea id="source"></textarea>
  `;

  const routerPortEl = ctx.root.querySelector("#router-port");
  routerPortEl.value = payload.port;

  routerPortEl.addEventListener("change", (event) => {
    ctx.pushEvent("update", { port: event.target.value });
  });

  const textarea = ctx.root.querySelector("#source");
  textarea.value = payload.source;

  textarea.addEventListener("change", (event) => {
    ctx.pushEvent("update", { source: event.target.value });
  });

  ctx.handleEvent("update", ({ port, source }) => {
    routerPortEl.value = port;
    textarea.value = source;
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change"));
  });
}
