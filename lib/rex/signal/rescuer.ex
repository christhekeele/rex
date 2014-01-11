defmodule Rex.Signal.Rescuer do

  @moduledoc """
  Ways to rescue signal errors.

  Rescuers are triggered when unhandled errors occur during an iteration
  of a signal.

  They accept the error raised, and the current state of the signal.

  They must return one of:

    - `{ loggable, new_state }`

      where `loggable` is sent to the signal's logs, and `new_state` is
      the new value of the signal's state.

    - `nil`

      to terminate this signal's iteration.
  """

  defdelegate default, to: __MODULE__, as: :log_error

  def log_error do
    fn error, state ->
      { { :error, state }, state }
    end
  end

end
