Rex
===

Rex is an attempt to add high-level, lightweight, dynamic abstractions of time-mutating values, and thereby native OTP constructs, futures, reactive programming, and entity-component-system data modeling, to Elixir.

Right now it's more of a sandbox and repository of ideas. Hopefully the two will grow ever closer in implementation! In the meantime, expect names, implementations, basic logic, and pretty much everything to change.

Goals
-----

- Abstract common patterns of message sending, process spawning, and the like through functional composition with native Elixir tools.

- Build pre-defined abstractions, and template and helper functions, for as many parts of the composition as possible.

- Build a robust DSL for defining the most common signals.

- Create abstractions around signals for common short-lived tasks like futures.

- Create abstractions around signals for common longer-lived tasks that rival OTP, but with a less implementation-leaking API and dynamic handlers.

- Explore other high-level abstractions available with these tool such as FRP, ECS, etc.

Signals
-------

### Signals

Signals (also commonly Behaviours in the FRP world, but that's taken) are observable data structures that live in their own processes, mutate over time, and have a well-formed API for communication. They should be implemented like lightweight GenServers: a good dsl for constructing synchronous and asynchronous calls, initialization and termination handlers, and making them easily sharable.

They're implemented entirely through function composition, streams, and primitive process+message handling.

The process of defining and starting a signal looks something like this:

```elixir
Rex.Signal[pid:
  Process.spawn_link(
    fn ->
      Stream.resource(
        initializer,
        fn state ->
          try do
            receive do
              { from, msg } -> handler.(from, msg, state)
              other         -> ignorer.(other, state)
            after timeout   -> idler.(state)
            end
          rescue
            error -> rescuer(error, state)
          end
        end,
        terminator
      ) |> Stream.each(logger) |> Stream.run
    end
  )
]
```

This process requires 7 functions and one value:

- `initializer/0`

  Lazily sets the initial state of the signal's running resource stream.

- `handler/3`

  The most important component: invoked on every received message, it steers the flow of all expected cases by acting on the sending process's pid, the message sent, and the state.

  It's also the first producer function: whatever its execution, it generally should return a two-tuple of the form: `{ loggable, new_state }`. We'll get into loggables in a bit.

- `ignorer/2`

  While all good handlers should have backup clauses for the unexpected, messages that don't match the standard anticipated `{ from_pid, msg }` format can be handled with an ignorer function that takes the rouge message and the state. It too must return as a producer.

  The (sensible) default for this is to do nothing, but log the occurrence and keep the state the same.

- `timeout // :infinity`

  If `timeout` is set to anything other than `:infinity`, the `idler/1` function is invoked.

- `idler/1`

  In the event of a timeout, the idler is invoked on the state. Note that it shouldn't be used for cleanup, but rather, for specific, intended behaviour if you're harnessing timeouts for some purpose. It too must act as a producer.

  The sensible default for an idler is to return `nil` instead of a `{ loggable, new_state }`, effectively terminating the stream. However, it can also be used in conjunction with a timeout to perform regular actions during inactive periods.

- `rescuer/2`

  The last function that must act as a producer, the rescuer catches exceptions and the state and decides where to go from there.

- `terminator/1`

  Should the stream end (by a producer returning `nil`), the terminator takes in the state and performs any cleanup.

- `logger/1`

  Finally, since the entire signal is implemented as a stream that emits values, the logger catches all `loggables` emitted by producers and does whatever you want it to.

Obviously, the core function to focus on is the `handler`. A DSL for defining robust handlers, as well as a standard API for them, is priority number one.

As patterns and DSLs emerge, the way these composed functions interact will likely be refined. Some behaviours may be predetermined to the extent that end users will lose the ability to select them all together. We'll see.

#### Notes

- With the continuable stream API, hot code swapping is a simple as sending a state-transformation function and a new handler to the signal at an anticipated endpoint. When it receives it, it can update its state and resume on next step with the new stream (at least in my head that should work).

Abstractions
------------

With these primitives, lofty realms of high-level abstraction are possible.

### GenServers

Signals pretty much are GenServers, implemented in Elixir. I'm just avoiding naming confusion for now.

### FSM

FSM are just specialized versions of servers, say the Erlang docs. So we'll specialize the servers to get these. Magic goes here; I've never really used FSM in Elixir yet and haven't looked over the Erlang implementation.

### Supervisors

Lordie I don't even know. One step at a time.

### Futures and promises

Futures are placeholders for yet unfinished computations. Promises are asynchronously calculated results to a computation, retrievable at a later date. The two are frequently found together.

Futures are datastructures that can be defined initially, used within code, and on being asked to read from, they hang until a promise delivers. Promises are computations whose application executes in another process, emits a result on completion, and closes itself down.

### Composite signals

Composite signals (or computed variables) are signals that depend on one or more changing values, ie. other signals. Their handlers can be expressed as calls that fetch the values of its observed signals and performs a calculation on them, returning the result to the caller.

### Event managers

Event managers are signals whose state is a list of subscribers. When they receive events, they broadcast them to their subscribers.

Subscribing to specific events could take place either on the signal or the subscriber: the signal could track which specific event names its subscribers are interested in, or the subscribers could open up a message stream around their own inbox and `Stream.filter` them. The former has the advantage of less process traffic.

### Reactive signals

If composite signals are lazily computed values, reactive signals are aggressively computed ones. They marry composite signals with event managers and promises: instead of being simple server/signals, the observed signals would double as event manager. Every time a signal upon which the composite signal is based changes, the observable would emit its new value to the composite, triggering a recalculation of its state. Consuming processes would access the composite through a future, so that the reactive signal never needs to trigger computation of its value on demand: it's either immediate because it's precalculated, or it will hang until re-calculation is complete and delivered as a promise to the consumer accessing it as a future.

### Entity-Component-Systems

Somewhere in all of this reactiveness, event sending, precomputation, and filtering event streams, I suspect there's a way to implement ECSs as well. I'll have to think on it.
