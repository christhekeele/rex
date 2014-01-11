defmodule Rex.Signal.Idler do

  @moduledoc """
  Common ways to handle signal timeouts.
  """

  defdelegate default(state), to: __MODULE__, as: :close_stream

  def close_stream(_state) do
    nil
  end

end
