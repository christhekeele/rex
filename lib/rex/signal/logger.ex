defmodule Rex.Signal.Logger do

  @moduledoc """
  Common ways to log signal activity.

  Since the loop that drives signals running streams, at every step they have an
  opportunity to log their activities. These emitted values are sent to loggers.

  Loggers accept a single parameter: whatever representation of signal activity
  the signal chooses to emit.

  Their return values are ignored.
  """

  defdelegate default, to: __MODULE__, as: :silent

  def output do
    fn event ->
      { self, event } |> inspect |> IO.puts
    end
  end

  def silent do
    fn _ ->
      nil
    end
  end

end
