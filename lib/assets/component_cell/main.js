export function init(ctx, payload) {
  ctx.importCSS("main.css");

  ctx.root.innerHTML = `
  <div>
    <select name="type" id="component-type">
      <option value="get">GET</option>
      <option value="post">POST</option>
      <option value="put">PUT</option>
      <option value="patch">PATCH</option>
      <option value="delete">DELETE</option>
    </select>
    <input type="text" id="component-path"></input>
  </div>
  <label for="available-assigns">Assigns</label>
  <textarea name="available-assigns" id="component-assigns"></textarea>
  <label for="html">HTML</label>
  <textarea name="html" id="html"></textarea>
  `;

  const componentTypeEl = ctx.root.querySelector("#component-type");
  componentTypeEl.value = payload.type;
  componentTypeEl.addEventListener("change", (event) => {
    ctx.pushEvent("update", { type: event.target.value });
  });

  const componentPathEl = ctx.root.querySelector("#component-path");
  componentPathEl.value = payload.path;
  componentPathEl.addEventListener("change", (event) => {
    const path = event.target.value;
    const pathParams = getPathParams(path);
    ctx.pushEvent("update", { path: path, assigns: getDefaultAssigns(pathParams) });
  });

  const componentAssignsEl = ctx.root.querySelector("#component-assigns");
  componentAssignsEl.value = payload.assigns;
  componentAssignsEl.addEventListener("change", (event) => {
    ctx.pushEvent("update", { assigns: event.target.value });
  });

  const textarea = ctx.root.querySelector("#html");
  textarea.value = payload.html;
  textarea.addEventListener("change", (event) => {
    ctx.pushEvent("update", { html: event.target.value });
  });

  ctx.handleEvent("update", ({ type, path, assigns, html }) => {
    componentTypeEl.value = type;
    componentPathEl.value = path;
    componentAssignsEl.value = assigns;
    textarea.value = html;
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change"));
  });
}

function getDefaultAssigns(pathParams) {
  return `assigns = %{
  ${pathParams.map(param => `${param}: conn.path_params["${param}"],`).join("\n  ")}
  params: conn.params
}`;
}

function getPathParams(path) {
  let segments = path.split("/");
  segments = segments.filter(segment => segment.startsWith(":"));
  return segments.map(segment => segment.substring(1));
}
