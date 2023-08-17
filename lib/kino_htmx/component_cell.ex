defmodule KinoHtmx.ComponentCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/component_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "HTMX Component"

  @impl true
  def init(attrs, ctx) do
    type = attrs["type"] || "get"
    path = attrs["path"] || "/"
    assigns = attrs["assigns"] || "%{}"
    html = attrs["html"] || ""

    ctx =
      assign(ctx,
        type: type,
        path: path,
        assigns: assigns,
        html: html
      )

    {:ok, ctx, reevaluate_on_change: true}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok,
     %{
       type: ctx.assigns.type,
       path: ctx.assigns.path,
       assigns: ctx.assigns.assigns,
       html: ctx.assigns.html
     }, ctx}
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
    %{
      "type" => ctx.assigns.type,
      "path" => ctx.assigns.path,
      "assigns" => ctx.assigns.assigns,
      "html" => ctx.assigns.html
    }
  end

  @impl true
  def to_source(attrs) do
    attrs
    |> to_quoted()
    |> Kino.SmartCell.quoted_to_string()
  end

  def to_quoted(%{
        "type" => type,
        "path" => path,
        "assigns" => assigns,
        "html" => html
      }) do
    module_name =
      Module.concat([Htmx.Component, String.capitalize(type), path_to_module_name(path)])

    quote do
      defmodule unquote(module_name) do
        use Htmx.Component, type: unquote(type), path: unquote(path)

        def mount(conn) do
          unquote(assigns |> Code.string_to_quoted!())
          {:ok, conn}
        end

        def render(assigns) do
          unquote(
            """
              ~HTMX\"\"\"
              #{html}
              \"\"\"
            """
            |> Code.string_to_quoted!()
          )
        end
      end

      unquote(module_name).kino_output()
    end
  end

  defp path_to_module_name(path) do
    path
    |> String.split("/", trim: true)
    |> Enum.reject(&String.starts_with?(&1, ":"))
    |> Enum.map(&String.capitalize/1)
    |> Enum.join()
  end
end
