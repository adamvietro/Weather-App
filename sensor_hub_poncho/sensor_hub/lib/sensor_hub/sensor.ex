defmodule SensorHub.Sensor do
  @moduledoc """
  Documentation for `Sensor`.
  """
  defstruct [:name, :fields, :read, :convert]

  def new(name) do
    %__MODULE__{
      read: read_fn(name),
      convert: convert_fn(name),
      fields: fields_fn(name),
      name: name
    }
  end

  def fields_fn(Sgp40), do: [:voc_index]
  def fields_fn(Bmp280), do: [:temperature_c, :pressure_pa, :altitude_m]
  def fields_fn(Tsl25911fn), do: [:light_lumens]
  def fields_fn(Ltr390uv), do: [:uv_index, :als_lux]

  def read_fn(Sgp40), do: fn -> Sgp40.get_measurement() end
  def read_fn(Bme280), do: fn -> Bme280.get_measurement() end
  def read_fn(TSL25911FN), do: fn -> TSL25911FN.get_measurement() end
  def read_fn(LTR390_UV), do: fn -> LTR390_UV.get_measurement() end

  def convert_fn(Sgp40) do
    fn reading ->
      Map.take(reading, [:voc_index])
    end
  end

  def convert_fn(Bme280) do
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
