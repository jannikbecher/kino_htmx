defmodule Htmx.Router do
  @moduledoc """

  """

  defstruct [:port]

  def kino_output(port) do
    %__MODULE__{port: port}
  end
end
