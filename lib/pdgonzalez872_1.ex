defmodule Solution1 do
  @moduledoc """
  Filter + Map solution
  """

  def parse(input) do
    %{original: input, newline_split: String.split(input, "\n", trim: true)}
    |> get_request_id()
    |> get_lines()
    |> get_report()
  end

  defdelegate get_request_id(input), to: Core

  def get_lines(%{newline_split: input} = state) do
    lines =
      input
      |> Enum.filter(fn el -> String.contains?(el, "INFO") end)
      |> Enum.map(fn el ->
        [timestamp, _, level, message] = String.split(el, "\t")

        %{
          timestamp: timestamp,
          level: level,
          message: message
        }
      end)

    Map.put(state, :lines, lines)
  end

  defdelegate get_report(input), to: Core
end
