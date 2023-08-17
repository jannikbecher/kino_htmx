defmodule Htmx.Component do
  @moduledoc """
  A module for building and managing HTMX components.

  This module provides a set of behaviours and 

  ## Callbacks
  - `mount/1`: Fetches data for the render function in stores it in the connection.
  - `render/1`: Renders the component to a HTML string.

  ## Usage

  You can either use the SmartCell `KinoHtmx.ComponentCell` or
  define your own cell:

      defmodule Htmx.Component.Get.Path do
        use Htmx.Component, method: "get", path: "/path"

        def mount(conn), do: {:ok, conn}

        def render(assigns), do: ~HTMX"<h1>Hello World"
      end
    
  For the module name you need to use the following scheme:
  `Htmx.Compnent.<method>.<path>` so the router can automatically
  create the routes.

  """

  @callback mount(Plug.Conn.t()) :: {:ok, Plug.Conn.t()}
  @callback render(map()) :: String.t()
  defmacro __using__(opts) do
    method = Keyword.get(opts, :method)
    path = Keyword.get(opts, :path)

    quote do
      @behaviour Htmx.Component

      import Plug.Conn
      import Htmx

      def init(opts), do: opts

      def call(conn, _opts) do
        {:ok, conn} = mount(conn)
        html = render(conn.assigns)
        send_resp(conn, 200, html)
      end

      def component_struct() do
        Htmx.Component.new(__MODULE__, unquote(method), unquote(path), "")
      end

      def component_struct(html) do
        Htmx.Component.new(__MODULE__, unquote(method), unquote(path), html)
      end

      def kino_output() do
        conn = Plug.Test.conn(unquote(method), unquote(path))
        {:ok, conn} = mount(conn)
        # TODO: generate random data
        assigns =
          Enum.map(conn.assigns, fn {k, v} ->
            {k,
             Enum.random([
               "Fluctuate",
               "Nebulous",
               "Labyrinth",
               "Quintessential",
               "Serendipity",
               "Mosaic",
               "Juxtapose",
               "Galvanize",
               "Idiosyncratic",
               "Perpendicular"
             ])}
          end)

        html = render(assigns)
        component_struct(html)
      end

      defp assign(conn, keyword) do
        Enum.reduce(keyword, conn, fn {key, value}, acc ->
          assign(acc, key, value)
        end)
      end
    end
  end

  defstruct [:module, :method, :path, :html]

  def new(module, method, path, html) do
    %__MODULE__{
      module: module,
      method: method,
      path: path,
      html: html
    }
  end
end
