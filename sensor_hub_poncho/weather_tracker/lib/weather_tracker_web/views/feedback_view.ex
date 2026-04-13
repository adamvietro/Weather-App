defmodule WeatherTrackerWeb.FeedbackView do
  use WeatherTrackerWeb, :view

  def temperature_ranges do
    [
      %{level: :low, min: nil, max: 17.9, color: "blue"},
      %{level: :normal, min: 18.0, max: 24.0, color: "green"},
      %{level: :high, min: 24.1, max: 27.0, color: "yellow"},
      %{level: :highest, min: 27.1, max: nil, color: "red"}
    ]
  end

  def humidity_ranges do
    [
      %{level: :low, min: 10.0, max: 29.9, color: "blue"},
      %{level: :normal, min: 30.0, max: 60.0, color: "green"},
      %{level: :high, min: 60.1, max: 70.0, color: "yellow"},
      %{level: :highest, min: 70.1, max: nil, color: "red"}
    ]
  end

  def voc_ranges do
    [
      %{level: :normal, min: 0, max: 100, color: "green"},
      %{level: :high, min: 101, max: 200, color: "yellow"},
      %{level: :highest, min: 201, max: nil, color: "red"}
    ]
  end

  def uv_ranges do
    [
      %{level: :normal, min: 0.0, max: 2.0, color: "green"},
      %{level: :high, min: 2.1, max: 5.0, color: "yellow"},
      %{level: :highest, min: 5.1, max: nil, color: "red"}
    ]
  end

  def als_ranges do
    [
      %{level: :low, min: nil, max: 99, color: "blue"},
      %{level: :normal, min: 100, max: 500, color: "green"},
      %{level: :high, min: 501, max: 1000, color: "yellow"},
      %{level: :highest, min: 1001, max: nil, color: "red"}
    ]
  end

  def light_ranges do
    [
      %{level: :low, min: nil, max: 99, color: "blue"},
      %{level: :normal, min: 100, max: 500, color: "green"},
      %{level: :high, min: 501, max: 1000, color: "yellow"},
      %{level: :highest, min: 1001, max: nil, color: "red"}
    ]
  end

  def status_for_value(value, ranges) do
    value = to_number(value)

    Enum.find(ranges, List.last(ranges), fn range ->
      in_range?(value, range.min, range.max)
    end)
  end

  def status_label(value, ranges) do
    value
    |> status_for_value(ranges)
    |> Map.fetch!(:level)
    |> humanize_level()
  end

  def border_class(value, ranges) do
    case status_for_value(value, ranges).color do
      "blue" -> "border-blue"
      "green" -> "border-green"
      "yellow" -> "border-yellow"
      "red" -> "border-red"
      _ -> "border-gray"
    end
  end

  def badge_class(value, ranges) do
    case status_for_value(value, ranges).color do
      "blue" -> "badge-blue"
      "green" -> "badge-green"
      "yellow" -> "badge-yellow"
      "red" -> "badge-red"
      _ -> "badge-gray"
    end
  end

  def fill_class(value, ranges) do
    case status_for_value(value, ranges).color do
      "blue" -> "fill-blue"
      "green" -> "fill-green"
      "yellow" -> "fill-yellow"
      "red" -> "fill-red"
      _ -> "fill-gray"
    end
  end

  def chart_color(value, ranges) do
    case status_for_value(value, ranges).color do
      "blue" -> "#3b82f6"
      "green" -> "#10b981"
      "yellow" -> "#f59e0b"
      "red" -> "#f43f5e"
      _ -> "#9ca3af"
    end
  end

  def line_color_for_field(:temperature_c), do: "#10b981"
  def line_color_for_field(:humidity_rh), do: "#10b981"
  def line_color_for_field(:voc_index), do: "#f43f5e"
  def line_color_for_field(:light_lumens), do: "#3b82f6"
  def line_color_for_field(:uv_index), do: "#10b981"
  def line_color_for_field(:als_lux), do: "#f59e0b"
  def line_color_for_field(_), do: "#6b7280"

  def clamp_percent(value, min_value, max_value) do
    value = to_number(value)
    min_value = to_number(min_value)
    max_value = to_number(max_value)

    if max_value <= min_value do
      0
    else
      percent = (value - min_value) / (max_value - min_value) * 100

      percent
      |> max(0.0)
      |> min(100.0)
      |> Float.round(1)
    end
  end

  def latest_metric(weather_conditions, field) do
    weather_conditions
    |> List.last()
    |> case do
      nil -> 0
      item -> Map.get(item, field) |> to_number()
    end
  end

  def normal_min(ranges) do
    ranges
    |> Enum.find(fn r -> r.level == :normal end)
    |> Map.get(:min)
    |> to_number()
  end

  def normal_max(ranges) do
    ranges
    |> Enum.find(fn r -> r.level == :normal end)
    |> Map.get(:max)
    |> to_number()
  end

  def chart_points_with_ranges(weather_conditions, field, ranges, width, height) do
    values =
      weather_conditions
      |> Enum.map(&Map.get(&1, field))
      |> Enum.map(&to_number/1)

    if length(values) < 2 do
      ""
    else
      actual_min = Enum.min(values)
      actual_max = Enum.max(values)

      norm_min = normal_min(ranges)
      norm_max = normal_max(ranges)

      min_value = min(actual_min, norm_min)
      max_value = max(actual_max, norm_max)

      spread = max(max_value - min_value, 0.0001)
      count = length(values)
      step_x = width / (count - 1)

      values
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        x = index * step_x
        y = height - (value - min_value) / spread * (height - 12) - 6
        "#{Float.round(x, 2)},#{Float.round(y, 2)}"
      end)
      |> Enum.join(" ")
    end
  end

  def chart_min_with_ranges(weather_conditions, field, ranges) do
    actual_min =
      weather_conditions
      |> Enum.map(&Map.get(&1, field))
      |> Enum.map(&to_number/1)
      |> Enum.min(fn -> 0 end)

    norm_min = normal_min(ranges)

    min(actual_min, norm_min)
    |> format_value()
  end

  def chart_max_with_ranges(weather_conditions, field, ranges) do
    actual_max =
      weather_conditions
      |> Enum.map(&Map.get(&1, field))
      |> Enum.map(&to_number/1)
      |> Enum.max(fn -> 0 end)

    norm_max = normal_max(ranges)

    max(actual_max, norm_max)
    |> format_value()
  end

  def format_value(value) do
    value = to_number(value)

    if is_float(value) do
      :erlang.float_to_binary(value, decimals: 1)
    else
      to_string(value)
    end
  end

  def sparkline_points(values, width, height) do
    values =
      values
      |> Enum.take(-10)
      |> Enum.map(&to_number/1)

    if length(values) < 2 do
      ""
    else
      min_value = Enum.min(values)
      max_value = Enum.max(values)
      spread = max(max_value - min_value, 0.0001)
      count = length(values)
      step_x = width / (count - 1)

      values
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        x = index * step_x
        y = height - (value - min_value) / spread * (height - 8) - 4
        "#{Float.round(x, 2)},#{Float.round(y, 2)}"
      end)
      |> Enum.join(" ")
    end
  end

  def humanize_level(:low), do: "Low"
  def humanize_level(:normal), do: "Normal"
  def humanize_level(:high), do: "High"
  def humanize_level(:highest), do: "Highest"
  def humanize_level(other), do: other |> to_string() |> String.capitalize()

  defp in_range?(_value, nil, nil), do: true
  defp in_range?(value, nil, max), do: value <= to_number(max)
  defp in_range?(value, min, nil), do: value >= to_number(min)
  defp in_range?(value, min, max), do: value >= to_number(min) and value <= to_number(max)

  defp to_number(%Decimal{} = value), do: Decimal.to_float(value)
  defp to_number(value) when is_integer(value), do: value
  defp to_number(value) when is_float(value), do: value
  defp to_number(nil), do: 0
end
