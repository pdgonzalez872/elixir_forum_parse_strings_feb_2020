defmodule Feb20Test do
  @moduledoc """
  Source: https://elixirforum.com/t/parse-this-string/29252

  Human friendly input:
  ```
  START RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69 Version: $LATEST
  2020-02-19T17:32:52.353Z        4d0ff57e-4022-4bfd-8689-a69e39f80f69    INFO    Getting metadata
  2020-02-19T17:32:52.364Z        4d0ff57e-4022-4bfd-8689-a69e39f80f69    INFO    Getting projects
  2020-02-19T17:32:52.401Z        4d0ff57e-4022-4bfd-8689-a69e39f80f69    INFO    Getting Logflare sources
  END RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69
  REPORT RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69  Duration: 174.83 ms     Billed Duration: 200 ms Memory Size: 1024 MB    Max Memory Used: 84 MB
  ```

  Would be helpful if you had more of examples of these.
  """

  use ExUnit.Case

  setup do
    input =
      "START RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69 Version: $LATEST\n2020-02-19T17:32:52.353Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting metadata\n2020-02-19T17:32:52.364Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting projects\n2020-02-19T17:32:52.401Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting Logflare sources\nEND RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\nREPORT RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\tDuration: 174.83 ms\tBilled Duration: 200 ms\tMemory Size: 1024 MB\tMax Memory Used: 84 MB\t\n"

    expected = %{
      request_id: "4d0ff57e-4022-4bfd-8689-a69e39f80f69",
      lines: [
        %{timestamp: "2020-02-19T17:32:52.353Z", level: "INFO", message: "Getting metadata"},
        %{timestamp: "2020-02-19T17:32:52.364Z", level: "INFO", message: "Getting projects"},
        %{
          timestamp: "2020-02-19T17:32:52.401Z",
          level: "INFO",
          message: "Getting Logflare sources"
        }
      ],
      report: %{
        "billed_duration_ms" => "200",
        "duration_ms" => "174.83",
        "max_memory_used_mb" => "84",
        "memory_size_mb" => "1024"
      }
    }

    {:ok, %{input: input, expected: expected}}
  end

  defmodule Core do
    def get_request_id(%{newline_split: [input | _]} = state) do
      [_, _, request_id, _, _] = String.split(input, " ")
      Map.put(state, :request_id, request_id)
    end

    def get_report(%{newline_split: input} = state) do
      [
        _,
        "Duration: " <> duration_ms,
        "Billed Duration: " <> billed_duration_ms,
        "Memory Size: " <> memory_size_mb,
        "Max Memory Used: " <> max_memory_used_mb
      ] = input |> Enum.at(-1) |> String.split("\t", trim: true)

      report = %{
        # I'm not going to parse this more than converting it to string. If you
        # want to do that, you can add a couple of functions that do that
        # below. They are staying as strings for now. If you will deal with
        # Floats, I suggest you look at the Decimal library and use that.
        "billed_duration_ms" => remove_metric(billed_duration_ms, "ms"),
        "duration_ms" => remove_metric(duration_ms, "ms"),
        "max_memory_used_mb" => remove_metric(max_memory_used_mb, "MB"),
        "memory_size_mb" => remove_metric(memory_size_mb, "MB")
      }

      Map.put(state, :report, report)
    end

    def remove_metric(input, to_replace) do
      input
      |> String.replace(" ", "")
      |> String.replace(to_replace, "")
    end
  end

  defmodule Solution1 do
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

  defmodule Solution2 do
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

  defmodule Solution3Greg do
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

  test "parses text as expected - Solution1", %{input: input, expected: expected} do
    result = Solution1.parse(input)

    assert result.request_id == "4d0ff57e-4022-4bfd-8689-a69e39f80f69"
    assert Enum.sort(result.lines) == Enum.sort(expected.lines)
    assert result.report == expected.report
  end

  test "parses text as expected - Solution2", %{input: input, expected: expected} do
    result = Solution2.parse(input)

    assert result.request_id == "4d0ff57e-4022-4bfd-8689-a69e39f80f69"
    assert Enum.sort(result.lines) == Enum.sort(expected.lines)
    assert result.report == expected.report
  end

  test "parses text as expected - Solution3Greg", %{input: input, expected: expected} do
    result = Solution3Greg.parse(input)

    assert result.request_id == "4d0ff57e-4022-4bfd-8689-a69e39f80f69"
    assert Enum.sort(result.lines) == Enum.sort(expected.lines)
    assert result.report == expected.report
  end
end
