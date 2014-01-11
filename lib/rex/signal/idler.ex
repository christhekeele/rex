defmodule Rex.Signal.Idler do

  @moduledoc """
  Common ways to handle signal timeouts.

  Idlers are invoked if a signal has a timeout set and it doesn't
  receive a message in that time period.

  They accept the current state of the signal.

  They must return one of:

    - `{ loggable, new_state }`

      where `loggable` is sent to the signal's logs, and `new_state` is
      the new value of the signal's state.

    - `nil`

      to terminate this signal's iteration.
  """

  defdelegate default, to: __MODULE__, as: :close_stream

  def close_stream do
    fn _ ->
      nil
    end
  end

end
