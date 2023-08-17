defmodule Kino.HtmxComponent do
  use Kino.JS

  def new(component) do
    Kino.JS.new(__MODULE__, component.html)
  end

  asset "main.js" do
    """
    export function init(ctx, html) {
      ctx.root.innerHTML = html;
    }
    """
  end
end
