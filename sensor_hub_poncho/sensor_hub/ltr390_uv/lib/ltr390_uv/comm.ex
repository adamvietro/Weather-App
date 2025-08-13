defmodule LTR390_UV.Comm do
  alias Circuits.I2C
  alias LTR390_UV.Config

  import Bitwise

  @command_bit 0x80
  @enable_register 0x00
  @gain_register 0x05
  @control_register 0x04
  @als_data_register [0x0D, 0x0E, 0x0F]
  @uvs_data_register [0x10, 0x11, 0x12]

  def discover(possible_addresses \\ [0x53]) do
    I2C.discover_one!(possible_addresses)
  end

  def open(bus_name) do
    {:ok, i2c} = I2C.open(bus_name)
    i2c
  end

  def write_config(config, i2c, sensor) do
    enable_byte = Config.to_enable_byte(config)
    control_byte = Config.to_control_byte(config)
    gain_byte = Config.to_gain_byte(config)

    # Write ENABLE register (1 byte) with command bit set
    I2C.write(i2c, sensor, <<@command_bit ||| @enable_register, enable_byte>>)

    # Write CONTROL register (1 byte) with command bit set
    I2C.write(i2c, sensor, <<@command_bit ||| @control_register, control_byte>>)

    # Write the GAIN register
    I2C.write(i2c, sensor, <<@command_bit ||| @gain_register, gain_byte>>)
  end

  def read(i2c, sensor, %Config{uvs_als: :uvs} = _config) do
    <<low, mid, high>> =
      I2C.write_read!(i2c, sensor, <<@command_bit ||| hd(@uvs_data_register)>>, 3)

    low ||| mid <<< 8 ||| high <<< 16
  end

  def read(i2c, sensor, %Config{uvs_als: :als} = config) do
    <<low, mid, high>> =
      I2C.write_read!(i2c, sensor, <<@command_bit ||| hd(@als_data_register)>>, 3)

    # Convert using ALS formula when you fix it
    raw = low ||| mid <<< 8 ||| high <<< 16
    Config.to_lumens(config, raw)
  end
end
