export async function init(ctx, payload) {
  await ctx.importJS("https://cdn.tailwindcss.com");

  ctx.root.innerHTML = `
  <div class="flex flex-col gap-4 bg-blue-200 p-4 border-solid rounded-lg border-2">
    <div class="flex items-center h-8 bg-blue-300 rounded-lg shadow-md">
      <p class="text-xl pl-2 w-32 text-gray-900">Settings</p>
      <div class="grow"></div>
      <div class="flex space-x-2 w-64">
        <label for="router-port" class="text-xl text-gray-900">Port:</label>
        <input id="router-port" type="text" class="w-16 text-xl text-gray-900 bg-blue-300 rounded-lg"></input>
      </div>
    </div>
    <span for="components-list" class="w-full text-xl font-bold text-gray-900">Available routes</span>
    <ul class="flex flex-col gap-1" id="components-list"></ul>
    <textarea class="w-full h-48 p-1 bg-blue-100 rounded-lg border-0" id="source"></textarea>
  </div>
  `;

  const routerPortEl = ctx.root.querySelector("#router-port");
  routerPortEl.value = payload.port;

  const componentsListEl = ctx.root.querySelector("#components-list");

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
    components.forEach((component) => {
      const liEl = document.createElement("li");
      liEl.classList.add(
        "flex",
        "text-base",
        "text-gray-900",
        "rounded-lg",
        "bg-blue-300"
      );
      liEl.innerHTML = `
        <span class="pl-4 w-1/6">
          ${component.method}
        </span>
        <span class="w-1/3">
          ${component.path}
        </span>
        <span class="w-1/2">
          <a href="#">${component.module}</a>
        </span>
      `;
      componentsListEl.appendChild(liEl);
    });
  });

  ctx.handleSync(() => {
    // Synchronously invokes change listeners
    document.activeElement &&
      document.activeElement.dispatchEvent(new Event("change"));
  });
}
