defmodule Kino.HtmxRouter do
  use Kino.JS

  def new(router) do
    Kino.JS.new(__MODULE__, router.port)
  end

  asset "main.js" do
    """
    export function init(ctx, port) {
      ctx.root.innerHTML = `
        <h1>The App is started under port ${port}.</h1>
        <h2><a target="_blank" href="#" id="app-link">Link to App</a></h2>
      `;
      const protocol = window.location.protocol;
      const hostname = window.location.hostname;
      document.getElementById("app-link").href = `${protocol}//${hostname}:${port}`;
    }
    """
  end
end
