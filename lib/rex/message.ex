defmodule Rex.Message do

  @moduledoc """
  Abstractions around receiving and checking messages.
  """

  @doc """
  Creates a stream that checks messages.

  Effectively a Stream.unfold wrapper around receive,
  with some boilerplate error rescuing.
  """
  defmacro stream(value // nil, code) do
    quote do
      Stream.unfold(
        unquote(initial(value)),
        unquote(iterator(code))
      )
    end
  end

  defp initial(value) do
    quote do: unquote(value)
  end

  @doc """
  Creates a message iterator function from a quoted expression.

  Expects the quoted expression to be valid arguments to `Kernel.recieve/1`,
  namely a code block constructed from the `:do` and `:after` keywords.

  Suitable for custom message streams as an argument to `Stream.repeatedly`,
  `Stream.unfold`, or `Stream.resource`.
  """
  def iterator(code) do
    quote do
      fn var!(state) ->
        try do
          receive(unquote(code))
        rescue
          error -> { { :error, error, var!(state) }, nil }
        end
      end
    end
  end

end
