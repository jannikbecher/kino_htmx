defmodule KinoHtmx do
  defdelegate iframe(), to: KinoHtmx.Iframe, as: :new
end
