Rex
===

Rex is an attempt to add high-level, lightweight, dynamic abstractions of time-mutating values, and thereby native OTP constructs, futures, reactive programming, and entity-component-system data modeling, to Elixir.

Right now it's more of a sandbox and repository of ideas. Hopefully the two will grow ever closer in implementation!

Goals
-----

The goals of Rex are four-fold:

- Build native Elixir tools around common patterns of message sending, process spawning, and the like
- Create abstractions around them for common short-lived tasks like futures
- Create abstractions around them for common longer-lived tasks that rival OTP, but with a less implementation-leaking API and dynamic handlers
- Explore other high-level abstractions available with these tool such as FRP, ECS, etc

Primitives
----------

The primitive building blocks of our abstractions themselves are built out of message streams.

### Message streams

Message streams wrap `receive` blocks with anonymous functions compliant with the Stream API.

They can be easily constructed using the `Message.stream` macro, and more custom ones with `Stream.repeatedly`, `Stream.unfold`, or `Stream.resource` in conjunction with a macro and `Message.iterator`.

The basic message iterator is an anonymous function that wraps a `receive` block.

Every received message should return either a two-tuple, `nil`, or a three-tuple of the format `{ :suspended, new_state, new_stream }`. The first element of the two tuple outputs to the stream, which is used by stream loggers. The second value is a state used in the next iteration. Returning `nil` terminates the stream, and the three-tuple allows you to migrate state and hot-code swap the stream in favor of another.

Examples can be found in `Message.Stream`.

### Signals

Signals (also commonly Behaviours in the FRP world, but that's taken) are observable data structures that mutate over time. They should be implemented like lightweight GenServers: a good dsl for constructing synchronous and asynchronous calls, initialization and termination handlers, and making them easily sharable.

Creating signals simply involves starting trying to fully enumerate message streams in another process, storing the pid for access, and sending it messages so it can step through the stream its running. Making them user-friendly is more difficult.

This will involve:

- coming up with a well-defined API for message stream responses that behave synchronously, asynchronously, and terminate cleanly in event of exception or request
- coming up with a DSL that abstracts the construction of message streams that conform to this API
- coming up with easy logging facilities
- implementing open and close type constructors for them
- coming up with temporary signal macros that handle opening and construction for you

#### Notes

- The term *signal* sometimes refers to a built-in combination of a *behaviour* (time-varying data) and its *events* in FRP. Rex signals are data sans events; furthermore, conflating the two is to create a latency-tolerant OOP system. Every effort is taken to keep signals from being misused as global variables or objects in Rex.

- With the continuable stream API, hot code swapping is a simple as sending a state-transformation function and a new message stream to the signal. When it receives it, it can update its state and resume on next call with the new stream (at least in my head that should work).

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
