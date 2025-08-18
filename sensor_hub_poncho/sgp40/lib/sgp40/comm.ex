defmodule Sgp40.Comm do
  alias Circuits.I2C
  alias Sgp40.Config
  alias Sgp40.CrcHelper

  @moduledoc """
  1. The sensor is powered up
  2. The I2C master periodically calls the measurement command and reads data in the following sequence:
    a. I2C master sends a measurement command.
    b. I2C master waits until the measurement is finished either by waiting for the maximum execution time or by waiting for the
    expected duration and then poll data until the read header is acknowledged by the sensor (expected durations are listed
    in Table 8).
  c. I2C master reads out the measurement result.
  """

  def discover(possible_addresses \\ [0x59]) do
    I2C.discover_one!(possible_addresses)
  end

  def open(bus_name) do
    {:ok, i2c} = I2C.open(bus_name)
    i2c
  end

  def close(i2c) do
    I2C.close(i2c)
  end

  def initialize_sensor(i2c, sensor) do
    with :ok <- I2C.write(i2c, sensor, Config.soft_reset()),
         :timer.sleep(10),
         :ok <- I2C.write(i2c, sensor, Config.self_test()),
         :timer.sleep(250),
         {:ok, <<msb, lsb, crc>>} <- I2C.read(i2c, sensor, 3),
         true <- CrcHelper.crc8(<<msb, lsb>>) == crc do
      {:ok, :test_passed}
    else
      {:error, reason} ->
        {:error, {:i2c_write_read_failed, reason}}

      false ->
        {:error, :crc_failed}
    end
  end

  def measure(i2c, sensor, config) do
    frame = Config.measure_frame(config)
    I2C.write(i2c, sensor, frame)
    # measurement duration
    :timer.sleep(30)
    # read 2-byte VOC + CRC for each
    I2C.read(i2c, sensor, 6)
  end
end
