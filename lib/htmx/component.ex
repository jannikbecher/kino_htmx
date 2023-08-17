defmodule Htmx.Component do
  @moduledoc """

  """
  @callback mount(Plug.Conn.t()) :: {:ok, Plug.Conn.t()}
  @callback render(map()) :: String.t()
  defmacro __using__(opts) do
    type = Keyword.get(opts, :type)
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

      def get_http_method, do: {unquote(type), unquote(path)}

      def kino_output() do
        conn = Plug.Test.conn(unquote(type), unquote(path))
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
        Htmx.Component.new(html)
      end

      defp assign(conn, keyword) do
        Enum.reduce(keyword, conn, fn {key, value}, acc ->
          assign(acc, key, value)
        end)
      end
    end
  end

  defstruct [:html]

  def new(html) do
    %__MODULE__{
      html: html
    }
  end
end
