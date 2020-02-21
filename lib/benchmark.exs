input =
  "START RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69 Version: $LATEST\n2020-02-19T17:32:52.353Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting metadata\n2020-02-19T17:32:52.364Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting projects\n2020-02-19T17:32:52.401Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting Logflare sources\nEND RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\nREPORT RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\tDuration: 174.83 ms\tBilled Duration: 200 ms\tMemory Size: 1024 MB\tMax Memory Used: 84 MB\t\n"

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

# Use Greg Vaugh's suggestion of using a for comprehension
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

defmodule TrarbrNimble do
  import NimbleParsec

  def parse(input) do
    {:ok, [result], _, _, _, _} = do_parse(input)

    {:ok, result}
  end

  def test() do
    {:ok,
     %{
       lines: [
         %{
           message: "Getting metadata",
           severity: "INFO",
           timestamp: "2020-02-19T17:32:52.353Z"
         },
         %{
           message: "Getting projects",
           severity: "INFO",
           timestamp: "2020-02-19T17:32:52.364Z"
         },
         %{
           message: "Getting Logflare sources\nOh see, it handles more than one line per message",
           severity: "INFO",
           timestamp: "2020-02-19T17:32:52.401Z"
         }
       ],
       report: %{
         "billed_duration_ms" => "174.83",
         "duration_ms" => "200",
         "max_memory_used_mb" => "1024",
         "memory_size_mb" => "84"
       },
       request_id: "4d0ff57e-4022-4bfd-8689-a69e39f80f69"
     }} == parse(test_input())
  end

  def test_input() do
    "START RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69 Version: $LATEST\n2020-02-19T17:32:52.353Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting metadata\n2020-02-19T17:32:52.364Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting projects\n2020-02-19T17:32:52.401Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting Logflare sources\nOh see, it handles more than one line per message\nEND RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\nREPORT RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\tDuration: 174.83 ms\tBilled Duration: 200 ms\tMemory Size: 1024 MB\tMax Memory Used: 84 MB\t\n"
  end

  # Example: 4d0ff57e-4022-4bfd-8689-a69e39f80f69

  uuid = ascii_string([], 36)

  # Example: 2020-02-19T17:32:52.353Z

  timestamp = ascii_string([?0..?9, ?-, ?:, ?., ?T, ?Z], 24)

  # Example: START RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69 Version: $LATEST\n

  start =
    ignore(string("START RequestId: "))
    |> concat(uuid)
    |> ignore(string(" Version: $LATEST\n"))

  # Example: END RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69

  end_ =
    ignore(string("END RequestId: "))
    |> concat(ignore(uuid))
    |> ignore(string("\n"))

  # Example: Getting metadata\n

  message_line =
    lookahead_not(choice([timestamp, end_]))
    |> optional(utf8_string([{:not, ?\n}], min: 1))
    |> ignore(string("\n"))

  # Example: It also\nworks with\nseveral lines

  message =
    message_line
    |> repeat()
    |> reduce({Enum, :join, ["\n"]})

  # Example: 2020-02-19T17:32:52.353Z\t4d0ff57e-4022-4bfd-8689-a69e39f80f69\tINFO\tGetting metadata\n

  logline =
    timestamp
    |> ignore(string("\t"))
    |> concat(ignore(uuid))
    |> ignore(string("\t"))
    |> ascii_string([?A..?Z], min: 1)
    |> ignore(string("\t"))
    |> concat(message)
    |> reduce({:to_logline, []})

  defp to_logline([ts, severity, message]) do
    %{
      timestamp: ts,
      severity: severity,
      message: message
    }
  end

  loglines =
    logline
    |> repeat()
    |> reduce({:to_loglines, []})

  defp to_loglines(loglines), do: loglines

  # Example: \nREPORT RequestId: 4d0ff57e-4022-4bfd-8689-a69e39f80f69\tDuration: 174.83 ms\tBilled Duration: 200 ms\tMemory Size: 1024 MB\tMax Memory Used: 84 MB\t\n

  report =
    ignore(string("REPORT RequestId: "))
    |> concat(ignore(uuid))
    |> ignore(string("\tDuration: "))
    |> ascii_string([?0..?9, ?.], min: 1)
    |> ignore(string(" ms\tBilled Duration: "))
    |> ascii_string([?0..?9, ?.], min: 1)
    |> ignore(string(" ms\tMemory Size: "))
    |> ascii_string([?0..?9, ?.], min: 1)
    |> ignore(string(" MB\tMax Memory Used: "))
    |> ascii_string([?0..?9, ?.], min: 1)
    |> ignore(string(" MB\t\n"))
    |> reduce({:to_report, []})

  defp to_report([duration, billed_duration, memory_size, max_memory_used]) do
    %{
      "billed_duration_ms" => duration,
      "duration_ms" => billed_duration,
      "max_memory_used_mb" => memory_size,
      "memory_size_mb" => max_memory_used
    }
  end

  parser =
    start
    |> concat(loglines)
    |> concat(end_)
    |> concat(report)
    |> reduce({:to_result, []})

  defp to_result([uuid, lines, report]) do
    %{
      request_id: uuid,
      lines: lines,
      report: report
    }
  end

  defparsecp(:do_parse, parser)
end

Benchee.run(%{
  "filter_map" => fn -> Solution1.parse(input) end,
  "reduce" => fn -> Solution2.parse(input) end,
  "for_comprehension" => fn -> Solution3Greg.parse(input) end,
  "trarbr_nimble" => fn -> TrarbrNimble.parse(input) end
})
