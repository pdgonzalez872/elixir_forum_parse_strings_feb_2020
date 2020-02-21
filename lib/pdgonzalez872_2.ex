defmodule Solution2 do
  @moduledoc """
  Reduce
  """

  def parse(input) do
    %{original: input, newline_split: String.split(input, "\n", trim: true)}
    |> get_request_id()
    |> get_lines()
    |> get_report()
  end

  defdelegate get_request_id(input), to: Core

  defp get_lines(%{newline_split: input} = state) do
    lines =
      input
      |> Enum.reduce([], fn el, acc ->
        el
        |> String.contains?("INFO")
        |> case do
          true ->
            [timestamp, _, level, message] = String.split(el, "\t")

            acc ++
              [
                %{
                  timestamp: timestamp,
                  level: level,
                  message: message
                }
              ]

          _ ->
            acc
        end
      end)

    Map.put(state, :lines, lines)
  end

  defdelegate get_report(input), to: Core
end

