defrecord Rex.Signal, pid: nil do

  @moduledoc """
  Start a new process, see the world, meet cool people.

  Starts message streams in new process, and saves the result in a record
  so other operations can be called on it, and so it can be passed around
  to other processes or functions cleanly.
  """

  def new(pid) do
    __MODULE__[pid: pid]
  end

  def open(msg_stream) do
    (fn -> msg_stream |> Stream.run end)
      |>  Process.spawn
      |>  new
  end

  def open(msg_stream, [logger: log_fn]) do
    (fn -> msg_stream |> Stream.each(log_fn) |> Stream.run end)
      |>  Process.spawn
      |>  new
  end

  def send(__MODULE__[pid: pid], msg) do
    pid <- { self, msg }
  end

  def close(__MODULE__[pid: pid]) do
    Process.exit pid, :kill
  end

end
