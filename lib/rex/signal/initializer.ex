defmodule Rex.Signal.Initializer do

  @moduledoc """
  Common ways to produce initial values for signals.

  Initializers are invoked when signals start to define their initial state.

  They accept no arguments.

  They return the starting state of the signal.
  """

  defdelegate default, to: __MODULE__, as: :value

  def value(value // nil) do
    fn -> value end
  end

end
