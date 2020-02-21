defmodule Core do
  @moduledoc """
  Basic functionality
  """

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
