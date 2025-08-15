defmodule Bme280.Comm do
  alias Circuits.I2C
  alias Bme280.Config

  import Bitwise

  @ctrl_hum 0xF2
  @ctrl_meas 0xF4
  @config_register 0xF5
  @data_register 0xF7

  def discover(possible_addresses \\ [0x76]) do
    I2C.discover_one!(possible_addresses)
  end

  def open(bus_name) do
    {:ok, i2c} = I2C.open(bus_name)
    i2c
  end

  def write_config(config, i2c, sensor) do
    ctrl_hum_byte = Config.to_ctrl_hum_byte(config)
    ctrl_meas_byte = Config.to_ctrl_meas_byte(config)
    config_byte = Config.to_config_byte(config)

    # Write CTRL_HUM register (1 byte)
    I2C.write(i2c, sensor, <<@ctrl_hum, ctrl_hum_byte>>)

    :timer.sleep(100)  # Small delay to ensure the sensor is ready

    # Write CTRL_MEAS register (1 byte)
    I2C.write(i2c, sensor, <<@ctrl_meas, ctrl_meas_byte>>)

    # Write CONFIG register (1 byte)
    I2C.write(i2c, sensor, <<@config_register, config_byte>>)
  end

  @doc """
  Still need to configure this but I think that we have something to start.
  """
  def read(i2c, sensor) do
    <<press_msb, press_lsb, press_xlsb, temp_msb, temp_lsb, temp_xlsb, hum_msb, hum_lsb>> =
      I2C.write_read!(i2c, sensor, <<@data_register>>, 8)

    combined_pressure = (press_msb <<< 12) ||| (press_lsb <<< 4) ||| (press_xlsb >>> 4)
    combined_temperature = (temp_msb <<< 12) ||| (temp_lsb <<< 4) ||| (temp_xlsb >>> 4)
    combined_humidity = (hum_msb <<< 8) ||| hum_lsb

    {combined_pressure, combined_temperature, combined_humidity}
  end
end
