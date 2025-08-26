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
    # Soft reset, ignore failure
    case I2C.write(i2c, sensor, Config.soft_reset()) do
      :ok -> IO.puts("Soft reset sent")
      {:error, :i2c_nak} -> IO.puts("Soft reset NAK, ignoring")
      {:error, reason} -> IO.puts("Soft reset error: #{inspect(reason)}, ignoring")
    end

    # Self-test
    case I2C.write(i2c, sensor, Config.self_test()) do
      :ok ->
        IO.puts("Self-test command sent")
        # give the sensor time
        :timer.sleep(300)

        case I2C.read(i2c, sensor, 3) do
          {:ok, <<msb, lsb, crc>>} ->
            IO.puts("Self-test returned: #{inspect({msb, lsb, crc})}")
            calculated_crc = CrcHelper.crc8(<<msb, lsb>>)
            IO.puts("Calculated CRC: #{calculated_crc}")

            if calculated_crc == crc do
              {:ok, :test_passed}
            else
              IO.puts("CRC failed: calculated #{calculated_crc}, sensor returned #{crc}")
              {:error, :crc_failed}
            end

          {:error, reason} ->
            IO.puts("I2C read failed: #{inspect(reason)}")
            {:error, {:i2c_write_read_failed, reason}}
        end

      {:error, reason} ->
        IO.puts("Self-test write failed: #{inspect(reason)}")
        {:error, {:i2c_write_read_failed, reason}}
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
