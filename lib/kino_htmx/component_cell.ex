defmodule KinoHtmx.ComponentCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/component_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "HTMX Component"

  @impl true
  def init(attrs, ctx) do
    type = attrs["type"] || "get"
    path = attrs["path"] || "/"
    html = attrs["html"] || ""

    ctx =
      assign(ctx,
        type: type,
        path: path,
        html: html
      )

    {:ok, ctx, reevaluate_on_change: true}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{type: ctx.assigns.type, path: ctx.assigns.path, html: ctx.assigns.html}, ctx}
  end

  @impl true
  def handle_event("update", params, ctx) do
    ctx =
      for {key, value} <- params, reduce: ctx do
        ctx -> assign(ctx, [{String.to_existing_atom(key), value}])
      end

    broadcast_event(ctx, "update", ctx.assigns)
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    %{"type" => ctx.assigns.type, "path" => ctx.assigns.path, "html" => ctx.assigns.html}
  end

  @impl true
  def to_source(%{"type" => type, "path" => path, "html" => html}) do
    quote do
      unquote(Macro.var(path_to_variable_name(path), __MODULE__)) =
        Htmx.Component.new(
          unquote(type),
          unquote(path),
          unquote(html)
        )
    end
    |> Kino.SmartCell.quoted_to_string()
  end

  defp path_to_variable_name(path) do
    path
    |> String.replace("/", "_")
    |> String.replace(":", "_")
    |> String.downcase()
    |> String.to_atom()
  end
end
