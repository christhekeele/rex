defmodule Rex.Signal.Rescuer do

  @moduledoc """
  Ways to rescue signal errors.
  """

  defdelegate default(error, state), to: __MODULE__, as: :log_error

  def log_error(error, state) do
    { { :error, state }, state }
  end

end
