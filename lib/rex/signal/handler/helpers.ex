defmodule Rex.Signal.Handler.Helpers do

  @moduledoc """
  Tools for building signal handlers.
  """

  defmacro handler(block) do
    # IO.puts inspect block
    # quote do
    #   fn
    #     (unquote(Dict.fetch!(block, :do)))
    #   end
    # end
  end

end
