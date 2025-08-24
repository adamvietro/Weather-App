defmodule SensorHub.Sensor do
  @moduledoc """
  Documentation for `Sensor`.
  """
  defstruct [:name, :fields, :read, :convert]

  def new(name) do
    %__MODULE__{
      read: read_fn(name),
      convert: convert_fn(name),
      fields: fields(name),
      name: name
    }
  end

  def fields(SPG40) when sgp40 in [:sgp40, "sgp40"], do: [:voc_index]
  def fields(BMP280) when bmp280 in [:bmp280, "bmp280"], do: [:temperature_c, :pressure_pa, :altitude_m]
  def fields(TSL25911FN) when tsl25911fn in [:tsl25911fn, "tsl25911fn"], do: [:light_lumens]
  def fields(LTR390_UV) when ltr390_uv in [:ltr390_uv, "ltr390_uv"], do: [:uv_index, :als_lux]

  def read(SPG40) when sgp40 in [:sgp40, "sgp40"], do: fn -> Sgp40.get_measurement() end
  def read(BMP280) when bmp280 in [:bmp280, "bmp280"], do: fn -> Bmp280.get_measurement() end
  def read(TSL25911FN) when tsl25911fn in [:tsl25911fn, "tsl25911fn"], do: fn -> Tsl25911fn.get_measurement() end
  def read(LTR390_UV) when ltr390_uv in [:ltr390_uv, "ltr390_uv"], do: fn -> Ltr390Uv.get_measurement() end

  def convert_fn(SGP40) do
    fn reading ->
      Map.take(reading, [:voc_index])
    end
  end

  def convert_fn(BMP280) do
    fn reading ->
      Map.take(reading, [:temperature_c, :pressure_pa, :altitude_m])
    end
  end

  def convert_fn(TSL25911FN) do
    fn reading ->
      Map.take(reading, [:light_lumens])
    end
  end

  def convert_fn(LTR390_UV) do
    fn reading ->
      Map.take(reading, [:uv_index, :als_lux])
    end
  end

  def measure(sensor) do
    sensor.read.()
    |> sensor.convert.()
  end
end
