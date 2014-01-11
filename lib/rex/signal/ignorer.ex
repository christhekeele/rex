defmodule Rex.Signal.Ignorer do

  @moduledoc """
  Common ways to ignore messages sent to signals that don't conform
  to the expected handler API.
  """

  defdelegate default(message, state), to: __MODULE__, as: :ignore

  @doc """
  Logs the fact that an unexpected message was received and ignored.

  Persists the state.
  """
  def ignore(message, state) do
    { :ignored, message, state }
  end

end
