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
  def scan_binding(pid, binding, _env) do
    send(pid, {:scan_binding_result, binding})
  end

  @impl true
  def handle_connect(ctx) do
    {:ok,
     %{port: ctx.assigns.port, source: ctx.assigns.source, components: ctx.assigns.components},
     ctx}
  end

  @impl true
  def handle_info({:scan_binding_result, binding}, ctx) do
    components =
      for {_key, val} <- binding, valid_data?(val) do
        Map.from_struct(val)
      end

    ctx = assign(ctx, components: components)

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
    quote do
      defmodule Router do
        use Plug.Router
        import Htmx.Component

        plug(Plug.Logger)
        plug(:match)
        plug(:dispatch)

        get "/" do
          send_resp(
            conn,
            200,
            unquote("""
            <html>
              <head>
                <title>HTMX</title>
                <script src="https://unpkg.com/htmx.org@1.9.4" integrity="sha384-zUfuhFKKZCbHTY6aRR46gxiqszMk5tcHjsVFxnUo8VMus4kHGVdIYVbOYYNlKmHV" crossorigin="anonymous"></script>
              </head>
              <body>
              #{attrs["source"]}
              </body>
            </html>
            """)
          )
        end

        unquote(
          for %{type: type, path: path, assigns: assigns, html: html} <- attrs["components"] do
            """
            #{type} "#{path}" do
              #{assigns}

              ~HTML\"\"\"
              #{html}
              \"\"\"
              |> Phoenix.HTML.Engine.encode_to_iodata!()
              |> Enum.join()
              |> then(&send_resp(conn, 200, &1))
            end
            """
          end
          |> Enum.join("\n\n")
          |> Code.string_to_quoted!()
        )

        match _ do
          send_resp(conn, 404, "not found")
        end
      end

      bandit = {Bandit, plug: Router, scheme: :http, port: unquote(attrs["port"])}
      Kino.start_child(bandit)
    end
    |> Kino.SmartCell.quoted_to_string()
  end

  defp valid_data?(%Htmx.Component{}), do: true
  defp valid_data?(_data), do: false
end
