export async function init(ctx, payload) {
  await ctx.importJS("https://cdn.tailwindcss.com");

  ctx.root.innerHTML = `
  <div class="flex flex-col gap-4 bg-blue-200 p-4 border-solid rounded-lg border-2">
    <div class="flex gap-4 h-8">
      <select class="w-24 rounded-lg shadow-md bg-blue-300 text-gray-900 pl-2" name="method" id="component-method">
        <option value="get">GET</option>
        <option value="post">POST</option>
        <option value="put">PUT</option>
        <option value="patch">PATCH</option>
        <option value="delete">DELETE</option>
      </select>
      <input class="w-full rounded-lg shadow-md bg-blue-300 pl-2" type="text" id="component-path"></input>
    </div>
    <div class="flex flex-col bg-blue-100 rounded-lg border-2 border-blue-500">
      <p class="w-full text-base text-gray-900">def mount(conn) do</p>
      <textarea class="w-full h-32 px-4 bg-blue-100 border-0" id="component-assigns"></textarea>
      <p class="w-full pl-4 text-base text-gray-900">{:ok, conn}</p>
      <p class="w-full text-base text-gray-900">end</p>
    </div>
    <div class="flex flex-col bg-blue-100 rounded-lg border-2 border-blue-500">
      <p class="w-full text-base text-gray-900">def render(assigns) do</p>
      <p class="w-full pl-4 text-base text-gray-900">~HTMX"""</p>
      <textarea class="w-full h-48 px-4 bg-blue-100 border-0" id="html"></textarea>
      <p class="w-full pl-4 text-base text-gray-900">"""</p>
      <p class="w-full text-base text-gray-900">end</p>
    </div>
  </div>
  `;

  const componentMethodEl = ctx.root.querySelector("#component-method");
  componentMethodEl.value = payload.method;
  componentMethodEl.addEventListener("change", (event) => {
    ctx.pushEvent("update", { method: event.target.value });
  });

  const componentPathEl = ctx.root.querySelector("#component-path");
  componentPathEl.value = payload.path;
  componentPathEl.addEventListener("change", (event) => {
    const path = event.target.value;
    const pathParams = getPathParams(path);
    ctx.pushEvent("update", {
      path: path,
      assigns: getDefaultAssigns(pathParams),
    });
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

  ctx.handleEvent("update", ({ method, path, assigns, html }) => {
    componentMethodEl.value = method;
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
  return `conn =
  assign(conn,
    ${pathParams
      .map((param) => `${param}: conn.path_params["${param}"],`)
      .join("\n  ")}
    params: conn.params
  )`;
}

function getPathParams(path) {
  let segments = path.split("/");
  segments = segments.filter((segment) => segment.startsWith(":"));
  return segments.map((segment) => segment.substring(1));
}
