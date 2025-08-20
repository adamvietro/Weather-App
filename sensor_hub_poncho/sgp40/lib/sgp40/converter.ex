defmodule Sgp40.Converter do
  import Bitwise
  @moduledoc """
  Converts temperature and humidity from human-readable values
  to SGP40 ticks for VOC compensation.
  """

  @doc """
  Convert temperature in °C to SGP40 ticks.
  Formula from SGP40 datasheet: T_ticks = ((T[°C] + 45) * 65535) / 175
  """
  def temperature_to_ticks(temp_c) when is_number(temp_c) do
    round((temp_c + 45) * 65_535 / 175)
  end

  @doc """
  Convert relative humidity %RH to SGP40 ticks.
  Formula from datasheet: RH_ticks = RH[%] * 65535 / 100
  """
  def humidity_to_ticks(humidity_rh) when is_number(humidity_rh) do
    round(humidity_rh * 65_535 / 100)
  end

  @doc """
  Convert a {temperature_c, humidity_rh} tuple to SGP40 ticks map
  """
  def from_bme({temp_c, humidity_rh}) do
    %{
      temperature_ticks: temperature_to_ticks(temp_c),
      humidity_ticks: humidity_to_ticks(humidity_rh)
    }
  end

  @doc """
  Convert raw ticks to {msb, lsb} tuple for the SGP40 CRC frame.
  """
  def to_tuple(ticks) when is_integer(ticks) do
    msb = ticks >>> 8 &&& 0xFF
    lsb = ticks &&& 0xFF
    {msb, lsb}
  end

  @doc """
  Convenience function: convert human-readable values directly to tuples
  for SGP40 measurement frame.
  """
  def human_to_tuple(temp_c, humidity_rh) do
    temp_tuple = temp_c |> temperature_to_ticks() |> to_tuple()
    hum_tuple = humidity_rh |> humidity_to_ticks() |> to_tuple()
    {temp_tuple, hum_tuple}
  end
end
