defmodule Kino.HtmxComponent do
  @moduledoc """
  A kino for rendering the content of a component.
  """

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
