defmodule Htmx.Router do
  @moduledoc """
  Struct for building router output.
  """

  defstruct [:port]

  def kino_output(port) do
    %__MODULE__{port: port}
  end
end
