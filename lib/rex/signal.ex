defrecord Rex.Signal, pid: nil do

  alias Rex.Signal.Initializer
  alias Rex.Signal.Handler
  alias Rex.Signal.Ignorer
  alias Rex.Signal.Idler
  alias Rex.Signal.Rescuer
  alias Rex.Signal.Terminator
  alias Rex.Signal.Logger

  @moduledoc """
  Start a new process, see the world, meet cool people. Elixir in a nutshell.

  Signals are simple records containing Pids, primed with
  functions to communicate between them.
  """

  def start(components // []) when is_list components do
    initializer = Dict.get(components, :initializer, &Initializer.default/0) # ✔︎
    handler     = Dict.get(components, :handler,     &Handler.default/3)     # ✔︎
    ignorer     = Dict.get(components, :ignorer,     &Ignorer.default/2)     # ✔︎
    idler       = Dict.get(components, :idler,       &Idler.default/1)       # ✔︎
    rescuer     = Dict.get(components, :rescuer,     &Rescuer.default/2)     # ✔︎
    terminator  = Dict.get(components, :terminator,  &Terminator.default/1)  # ✔︎
    logger      = Dict.get(components, :logger,      &Logger.default/1)      # ✔︎
    timeout     = Dict.get(components, :timeout,    :infinity)               # ✔︎
    start(initializer, handler, ignorer, idler, rescuer, terminator, logger, timeout)
  end

  def start(initializer, handler, ignorer, idler, rescuer, terminator, logger, timeout) do
    __MODULE__[pid:
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
                error -> rescuer.(error, state)
              end
            end,
            terminator
          ) |> Stream.each(logger) |> Stream.run
        end
      )
    ]
  end

  def send(__MODULE__[pid: pid], msg) do
    pid <- { self, msg }
  end

  def call(__MODULE__[pid: pid], msg) do
    pid <- { self, msg }
    receive do
      { ^pid, response } -> response
    end
  end

  def close(__MODULE__[pid: pid]) do
    Process.exit pid, :kill
  end

end
