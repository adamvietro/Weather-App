defmodule Bme280.Comm do
  alias Circuits.I2C
  alias Bme280.Config

  import Bitwise

  @ctrl_hum 0xF2
  @ctrl_meas 0xF4
  @config_register 0xF5

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

    # Write CTRL_MEAS register (1 byte)
    I2C.write(i2c, sensor, <<@ctrl_meas, ctrl_meas_byte>>)

    # Write CONFIG register (1 byte)
    I2C.write(i2c, sensor, <<@config_register, config_byte>>)
  end

  @doc """
  Still need to configure this but I think that we have something to start.
  """
  def read_config(i2c, sensor) do
    I2C.write(i2c, sensor, <<@config_register, 0x00>>)
    I2C.read(i2c, sensor, 1)
  end
end
