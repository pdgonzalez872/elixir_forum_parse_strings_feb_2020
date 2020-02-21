defmodule Solution3Greg do
  @moduledoc """
  Use Greg Vaugh's suggestion of using a for comprehension
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
      for el <- input,
          String.contains?(el, "INFO"),
          [timestamp, _, level, message] = String.split(el, "\t") do
        %{
          timestamp: timestamp,
          level: level,
          message: message
        }
      end

    Map.put(state, :lines, lines)
  end

  defdelegate get_report(input), to: Core
end
