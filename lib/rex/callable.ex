defprotocol Callable do

  @moduledoc """
  Structures that can be coerced into function calls.

  Mostly exists so novel ways of representing function calls can be
  triggered generically alongside standard ones.
  """

  @doc """
  Invoke a callable with the given arguments.
  """
  def call(callable, args // [])
end

defimpl Callable, for: Function do
  def call(fun, args)
    when is_function fun and is_list args do
    apply(fun, args)
  end
end

defimpl Callable, for: Tuple do
  def call({mod, fun}, args)
    when is_atom mod and is_atom fun and is_list args  do
    apply(mod, fun, args)
  end
end

defimpl Callable, for: Rex.Message.Handler do
  alias Rex.Message.Handler
  def call(handler, args)
    when is_record(handler, Handler) and is_list args  do
    handler
      |> Handler.compile
      |> Handler.call(args)
  end
end
