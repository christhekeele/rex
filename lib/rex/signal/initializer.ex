defmodule Rex.Signal.Initializer do

  @moduledoc """
  Common ways to produce initial values for signals.
  """

  defdelegate default, to: __MODULE__, as: :value

  def value(value // nil) do
    value
  end

end
