defmodule Rex.Message.Stream do
  import Rex.Message

  @moduledoc """
  A collection of useful message streams.

  Any stream that returns nil effectively closes the stream.
  """

  @doc """
  Accumulates received messages.
  """
  def accumulator(history // [], [timeout: timeout] // [timeout: :infinity]) do
    stream(history) do
      { pid, msg } ->
        { msg, [ msg | state ] }
    after timeout ->
      nil
    end
  end

  @doc """
  Yields values in the process mailbox.

  Accepts a pid to bind to a single source if desired.
  """
  def reader(from // nil, [timeout: timeout] // [timeout: :infinity]) do
    if from do
      stream(from) do
        { ^state, msg } -> { msg, state }
      after timeout ->
        nil
      end
    else
      stream(nil) do
        { _, msg } -> { msg, nil }
      after timeout ->
        nil
      end
    end
  end

  @doc """
  Stores a value allow it to be read/rewritten/updated.
  """
  def holder(state // nil, [timeout: timeout] // [timeout: :infinity]) do
    stream(state) do
      { from, { :get } } ->
        from <- state
        { { :get, from }, state }
      { from, { :put, new } } ->
        { { :put, from, new }, new }
      { from, { :update, fun } } ->
        new = fun.(state)
        { { :update, from, fun }, new }
    after timeout ->
      nil
    end
  end

  @doc """
  Forwards all received messages to a list of subscribers.
  """
  def forwarder(subscribers // [], [timeout: timeout] // [timeout: :infinity]) do
    subscribers = subscribers |> List.wrap |> HashSet.new
    stream(subscribers) do
      { pid, { :subscribe, subscriber } } ->
        { { :subscribed, subscriber }, Set.put(state, subscriber) }
      { pid, { :unsubscribe, subscriber } } ->
        { { :unsubscribed, subscriber }, Set.delete(state, subscriber) }
      { pid, msg } ->
        Enum.each( state, fn to_pid ->
          to_pid <- { pid, msg }
        end )
        { { :sent, msg, state }, state }
    after timeout ->
      nil
    end
  end

  @doc """
  Forwards tagged messages to subscribers of that tag.
  """
  def tagged_forwarder(subscriptions // [], [timeout: timeout] // [timeout: :infinity]) do
    subscriptions = List.wrap subscriptions
    stream(subscriptions) do
      { pid, { :subscribe, subscriber, tag } } ->
        { { :subscribed, subscriber, tag }, Keyword.put(state, tag, subscriber) }
      { pid, { :unsubscribe, subscriber, tag } } ->
        { { :unsubscribed, subscriber, tag }, Keyword.delete(state, tag, subscriber) }
      { pid, { tag, msg } } ->
        subscribers = Keyword.get_values(state, tag)
        Enum.each(subscribers, fn to_pid ->
          to_pid <- { pid, msg }
        end )
        { { :sent, msg, subscribers }, state }
    after timeout ->
      nil
    end
  end

  @doc """
  Constructs a generic signal stream from AST.

  Handlers is a dictionary of lists of different message handlers,
  following these conventions per signal type:

    - :calls

      A call handler is a two-tuple of AST: a pattern to match,
      and code to execute in the event of a match.
      The return value of the code becomes the new signal state

    - :casts

      casts
  """
  def signal(handlers) do

  end

end
