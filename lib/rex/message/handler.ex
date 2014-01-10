defrecord Rex.Message.Handler, actions: [], timeout: {:infinity, nil}, function: nil, dirty?: true do

  @moduledoc """
  Concept for a composable message handler: each clause/consequent of the receive block
  can be added, removed, or replaced individually, as well as timeout behaviour.
  When asked to be called, the handler (re)compiles itself into a valid message stream function.
  Dirty tracking on its components ensure it doesn't compile itself on every call.
  """

  @doc """
  Creates an AST representation of a message handler.
  """
  def build(__MODULE__[actions: actions, timeout: timeout]) do
    Rex.Message.iterator([
      do: [
            Enum.map(actions, fn { head, body } ->
              {:->, [], [[head], body]}
            end )
      ],
      after:  if timeout do
                {time, action} = timeout
                [{:->, [], [[time], action]}]
              end
    ])
  end

  @doc """
  Attempts to generate an anonymous function from a message handler.
  """
  def compile(handler=__MODULE__[dirty?: true]) do
    case Code.eval_quoted(handler.build) do
      { :error, reason } ->
        raise reason
      { function, _ } when is_function function ->
        handler.update(dirty?: false, function: function)
    end
  end
  def compile(handler=__MODULE__[dirty?: false]) do
    handler
  end

  @doc """
  Invokes the message handler with the given arguments.

  Re-compiles it if needed.
  """
  def call(handler=__MODULE__[dirty?: true], args) do
    call(handler.compile, args)
  end
  def call(handler=__MODULE__[function: function], args) do
    apply(function, args)
  end

# UPDATE OVERRIDES
# These examples won't actually work. They need to be implemented as macros so
#  they can catch actually compilable code, and `super` doesn't work for record
#  overrides anyways as far as I can tell. They're here so you get the idea:
#  quote a DSL, set it in the record, update :dirty?.

  # ACTIONS
  # def update(transforms=[{ :actions, new } | t], handler=__MODULE__[actions: old, dirty?: false])
  #   when new != old do
  #   super transforms, handler
  #   handler.update_dirty?(true)
  # end

  # def update(transforms=[{ :actions, fun } | t], handler=__MODULE__[dirty?: false])
  #   when is_function fun do
  #   super transforms, handler
  #   handler.update_dirty?(true)
  # end

  # def update_actions(new, handler=__MODULE__[actions: old, dirty?: false])
  #   when new != old do
  #   super actions, handler
  #   handler.update_dirty?(true)
  # end

  # # AFTER
  # def update(transforms=[{ :timeout, new } | t], handler=__MODULE__[timeout: old, dirty?: false])
  #   when new != old do
  #   super transforms, handler
  #   handler.update_dirty?(true)
  # end

  # def update(transforms=[{ :timeout, fun } | t], handler=__MODULE__[dirty?: false])
  #   when is_function fun do
  #   super transforms, handler
  #   handler.update_dirty?(true)
  # end

  # def update_timeout(new, handler=__MODULE__[timeout: old, dirty?: false])
  #   when new != old do
  #   super actions, handler
  #   handler.update_dirty?(true)
  # end

end
