defmodule Rex.Signal.Terminator do

  @moduledoc """
  Common ways to teardown signals.

  Terminators get invoked at the end of a signal's life. They can be
  used to alert other processes to its impending demise, or clean up
  opened resources.

  Things that cause signals to terminate:

  - Handlers, Ignorers, Idlers, or Rescuers returning nil
  - Errors bubbling past Handlers, Ignorers, Idlers, and even Rescuers
  - The terrifying and unforseen.

  Terminators accept the finalized state of the signal.

  Their return values are unused.
  """

  defdelegate default, to: __MODULE__, as: :do_nothing

  def do_nothing do
    fn _ ->
      nil
    end
  end

end
