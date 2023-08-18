defmodule KinoHtmx.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Kino.SmartCell.register(KinoHtmx.RouterCell)
    Kino.SmartCell.register(KinoHtmx.ComponentCell)

    children = []

    opts = [strategy: :one_for_one, name: KinoHtmx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
