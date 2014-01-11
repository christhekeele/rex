defmodule Rex.Signal.Handler do

  @moduledoc """
  Common signal handlers.
  """

  import __MODULE__.Helpers

  defdelegate default(from, msg, state), to: __MODULE__, as: :server

  def server(from, :get, state) do
    from <- { self, state }
    { { :got, [value: state, by: from] }, state }
  end
  def server(from, { :put, new_state }, _state) do
    { { :set, [to: new_state, by: from] }, new_state }
  end
  def server(from, { :update, transform }, state) do
    new_state = transform.(state)
    { { :updated, [with: transform, from: state, to: new_state, by: from] }, new_state }
  end

end
