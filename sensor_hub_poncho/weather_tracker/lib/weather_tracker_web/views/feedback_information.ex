defmodule WeatherTrackerWeb.FeedbackInformation do
  @moduledoc """
  Static information and descriptions for sensor data displayed
  in the feedback dashboard.
  """

  def sensor_help_items do
    [
      %{
        key: :temperature_c,
        title: "Temperature",
        description: "Ambient air temperature in Celsius.",
        normal: "18°C to 24°C"
      },
      %{
        key: :humidity_rh,
        title: "Humidity",
        description: "Relative humidity of the air.",
        normal: "30% to 60%"
      },
      %{
        key: :voc_index,
        title: "VOC Index",
        description: "Air quality indicator for volatile organic compounds.",
        normal: "Lower is generally better"
      },
      %{
        key: :uv_index,
        title: "UV Index",
        description: "Ultraviolet light level.",
        normal: "Usually very low indoors"
      },
      %{
        key: :als_lux,
        title: "ALS Lux",
        description: "Ambient light level measured in lux.",
        normal: "Depends on room brightness"
      },
      %{
        key: :light_lumens,
        title: "Light",
        description: "Calculated light reading from the TSL sensor.",
        normal: "May need calibration"
      }
    ]
  end
end
