defmodule Rex.Signal.Handler do

  @moduledoc """
  Common signal handlers.

  Handler accept three arguments: the instigating pid, the message sent,
  and the current state of the signal.

  They must return one of:

    - `{ loggable, new_state }`

      where `loggable` is sent to the signal's logs, and `new_state` is
      the new value of the signal's state.

    - `nil`

      to terminate this signal's iteration.
  """

  import __MODULE__.Helpers

  defdelegate default, to: __MODULE__, as: :server

  def server do
    fn
      from, :get, state ->
        from <- { self, state }
        { { :got, [value: state, by: from] }, state }

      from, { :put, new_state }, _state ->
        { { :set, [to: new_state, by: from] }, new_state }

      from, { :update, transform }, state ->
        new_state = transform.(state)
        { { :updated, [with: transform, from: state, to: new_state, by: from] }, new_state }
    end
  end

end
