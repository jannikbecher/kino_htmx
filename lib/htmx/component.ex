defmodule Htmx.Component do
  @callback mount(Plug.Conn.t()) :: {:ok, map()}
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
        {:ok, assigns} = mount(conn)
        html = render(assigns)
        send_resp(conn, 200, html)
      end

      def get_http_method, do: {unquote(type), unquote(path)}
    end
  end
end
