defmodule Rex.Signal.Logger do

  @moduledoc """
  Ways to log signal activity.
  """

  defdelegate default(log), to: __MODULE__, as: :output

  def output(log) do
    log |> inspect |> IO.puts
  end

  def silent(_log) do; end

end
