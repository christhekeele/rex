defmodule Rex.Signal.Terminator do

  @moduledoc """
  Common ways to teardown signals.
  """

  defdelegate default(state), to: __MODULE__, as: :nothing

  def nothing(_state) do
    nil
  end

end
