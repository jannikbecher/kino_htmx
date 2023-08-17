export function init(ctx, payload) {
  ctx.importCSS("main.css");

  ctx.root.innerHTML = `
  <input type="text" id="router-port"></input>
  <ul id="components-list"></ul>
  <textarea id="source"></textarea>
  `;

  const routerPortEl = ctx.root.querySelector("#router-port");
  routerPortEl.value = payload.port;

  const componentsListEl = ctx.root.querySelector("#components-list");
  console.log(payload)
  payload.components.forEach(component => {
    const liEl = document.createElement("li");
    liEl.textContent = `${component.method} ${component.path} -> ${component.module}`;
    componentsListEl.appendChild(liEl);
  });

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

  ctx.handleEvent("update_components", ({ components }) => {
    componentsListEl.innerHTML = "";
    components.forEach(component => {
      const liEl = document.createElement("li");
      liEl.innerHTML = `<span>${component.method} ${component.path} -> <a href="#">${component.module}</a></span>`;
      componentsListEl.appendChild(liEl);
    });
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change"));
  });
}
