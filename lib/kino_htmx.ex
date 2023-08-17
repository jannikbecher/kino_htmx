defimpl Kino.Render, for: Htmx.Component do
  def to_livebook(component) do
    component |> Kino.HtmxComponent.new() |> Kino.Render.to_livebook()
  end
end

defmodule KinoHtmx do
  defdelegate output(), to: KinoHtmx.Iframe, as: :new
end
