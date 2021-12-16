defmodule MusicDB.IntervalExtension do
  @behaviour Postgrex.Extension

  def init(_opts), do: nil

  def matching(_state), do: [send: "interval_send"]

  def format(_state), do: :binary

  def encode(_state) do
    quote do
      {months, days, seconds} ->
        microseconds = seconds * 1_000_000
        <<16::32, microseconds::64, days::32, months::32>>
    end
  end

  def decode(_state) do
    quote do
      <<16::32, microseconds::64, days::int32, months::int32>> ->
        seconds = div(microseconds, 1_000_000)
        {months, days, seconds}
    end
  end
end

Postgrex.Types.define(
  MusicDB.PostgrexTypes,
  [MusicDB.IntervalExtension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)
