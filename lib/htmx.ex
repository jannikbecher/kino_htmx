defmodule Htmx do
  defmacro sigil_HTMX({:<<>>, _meta, [expr]}, []) do
    unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
      raise "~HTMX requires a variable named \"assigns\" to exist and be set to a map"
    end

    options = [
      engine: Phoenix.HTML.Engine,
      source: expr
    ]

    EEx.compile_string(expr, options)
  end

  def render(htmx) do
    htmx
    |> Phoenix.HTML.Engine.encode_to_iodata!()
    |> IO.iodata_to_binary()
  end
end
