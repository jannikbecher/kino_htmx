defmodule KinoHtmx.RouterCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets/router_cell"
  use Kino.JS.Live
  use Kino.SmartCell, name: "HTMX Router"

  alias KinoHtmx.Settings

  @impl true
  def init(attrs, ctx) do
    port = attrs["port"] || 5000
    source = attrs["source"] || ""

    ctx =
      assign(ctx,
        port: port,
        source: source,
        components: []
      )

    {:ok, ctx, reevaluate_on_change: true}
  end

  @impl true
  def scan_binding(pid, _binding, %{context_modules: context_modules}) do
    modules =
      context_modules
      |> Enum.map(&Atom.to_string/1)
      |> Enum.filter(&String.starts_with?(&1, "Elixir.Htmx.Component"))
      |> Enum.map(&String.to_existing_atom/1)

    send(pid, {:scan_binding_result, modules})
  end

  @impl true
  def handle_connect(ctx) do
    {:ok,
     %{port: ctx.assigns.port, source: ctx.assigns.source, components: ctx.assigns.components},
     ctx}
  end

  @impl true
  def handle_info({:scan_binding_result, modules}, ctx) do
    ctx = assign(ctx, components: modules)
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update", params, ctx) do
    port = params["port"] || ctx.assigns.port
    source = params["source"] || ctx.assigns.source
    broadcast_event(ctx, "update", %{"port" => port, "source" => source})
    Settings.set_port(port)
    {:noreply, assign(ctx, port: port, source: source)}
  end

  @impl true
  def to_attrs(ctx) do
    %{
      "port" => ctx.assigns.port,
      "source" => ctx.assigns.source,
      "components" => ctx.assigns.components
    }
  end

  @impl true
  def to_source(attrs) do
    for quoted <- to_quoted(attrs), do: Kino.SmartCell.quoted_to_string(quoted)
  end

  defp to_quoted(attrs) do
    [
      quote do
        defmodule Htmx.Component.Get.Root do
          use Htmx.Component, method: "get", path: "/"

          def mount(conn), do: {:ok, conn}

          def render(assigns) do
            unquote(
              """
              ~HTMX\"\"\"
              <!DOCTYPE html>
              <html lang="en">
                <head>
                  <meta charset="UTF-8">
                  <meta http-equiv="X-UA-Compatible" content="IE=edge">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>HTMX</title>
                  <script src="https://unpkg.com/htmx.org@1.9.4" integrity="sha384-zUfuhFKKZCbHTY6aRR46gxiqszMk5tcHjsVFxnUo8VMus4kHGVdIYVbOYYNlKmHV" crossorigin="anonymous"></script>
                </head>
                <body>
                #{attrs["source"]}
                </body>
              </html>
              \"\"\"
              """
              |> Code.string_to_quoted!()
            )
          end
        end
      end,
      quote do
        defmodule Router do
          use Plug.Router

          plug(Plug.Logger)
          plug(:match)
          plug(:dispatch)

          get("/", to: Htmx.Component.Get.Root)

          unquote(
            for component <- attrs["components"] do
              {method, path} = component.get_http_method()
              "#{method} \"#{path}\", to: #{component}"
            end
            |> Enum.join("\n\n")
            |> Code.string_to_quoted!()
          )

          match _ do
            send_resp(conn, 404, "not found")
          end
        end
      end,
      quote do
        bandit = {Bandit, plug: Router, scheme: :http, port: unquote(attrs["port"])}
        Kino.start_child(bandit)
      end,
      quote do
        Htmx.Router.kino_output()
      end
    ]
  end
end
