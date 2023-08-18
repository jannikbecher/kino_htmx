defmodule KinoHtmx.Iframe do
  @moduledoc false

  use Kino.JS

  def new() do
    port = Application.get_env(:kino_htmx, :port, 8080)
    Kino.JS.new(__MODULE__, port)
  end

  asset "main.js" do
    """
    export function init(ctx, port) {
      const iframe = document.createElement("iframe");
      const src = window.location.protocol + "//" + window.location.hostname + ":" + port;
      iframe.setAttribute("src", src);
      iframe.style.width = "100%";
      iframe.style.height = "500px";
      iframe.style.border = "0";
      ctx.root.appendChild(iframe);
    }
    """
  end
end
