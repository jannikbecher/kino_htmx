defmodule KinoHtmx.Settings do
  @moduledoc false

  defstruct [:port]

  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %__MODULE__{port: 5000} end, name: __MODULE__)
  end

  def set_port(port), do: put(:port, port)

  def get_port(), do: get(:port)

  defp put(key, value) do
    Agent.update(__MODULE__, fn settings -> Map.put(settings, key, value) end)
  end

  defp get(key) do
    Agent.get(__MODULE__, fn settings -> Map.get(settings, key) end)
  end
end
