defmodule Htmx.Component do
  @moduledoc false

  defstruct [:type, :path, :assigns, :html]

  defmacro sigil_HTML({:<<>>, _meta, [expr]}, []) do
    unless Macro.Env.has_var?(__CALLER__, {:assigns, nil}) do
      raise "~HTML requires a variable named \"assigns\" to exist and be set to a map"
    end

    options = [
      engine: Phoenix.HTML.Engine,
      source: expr
    ]

    EEx.compile_string(expr, options)
  end

  def new(type, path, assigns, html) do
    %__MODULE__{
      type: type,
      path: path,
      assigns: assigns,
      html: html
    }
  end
end
