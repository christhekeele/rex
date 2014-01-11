defmodule Rex.Signal.Ignorer do

  @moduledoc """
  Common ways to ignore malformed messages to signals.

  These handlers are invoked when a signal receives something that doesn't
  conform to the expected handler API of `{ sending_pid, message }`.

  They accept the malformed message and the current signal state.

  They must return one of:

    - `{ loggable, new_state }`

      where `loggable` is sent to the signal's logs, and `new_state` is
      the new value of the signal's state.

    - `nil`

      to terminate this signal's iteration.
  """

  defdelegate default, to: __MODULE__, as: :log_malformed

  @doc """
  Logs the fact that an unexpected message was received and ignored.

  Persists the state.
  """
  def log_malformed do
    fn message, state ->
      { { :ignored, message, state }, state }
    end
  end

end
