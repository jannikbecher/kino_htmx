defmodule Htmx.Component do
  @moduledoc """

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
