defmodule KinoHtmx do
  defdelegate output(), to: KinoHtmx.Iframe, as: :new
end
