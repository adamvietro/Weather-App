defmodule TSL25911FN.Comm do
  alias Circuits.I2C
  alias TSL25911FN.Config

  import Bitwise

  @command_bit 0x80
  @enable_register 0x00
  @control_register 0x01
  @als_data_register 0x14

  def discover(possible_addresses \\ [0x29]) do
    I2C.discover_one!(possible_addresses)
  end

  def open(bus_name) do
    {:ok, i2c} = I2C.open(bus_name)
    i2c
  end

  def close(i2c) do
    I2C.close(i2c)
  end

  def write_config(config, i2c, sensor) do
    enable_byte = Config.to_enable_byte(config)
    control_byte = Config.to_control_byte(config)

    # Write ENABLE register (1 byte) with command bit set
    I2C.write(i2c, sensor, <<@command_bit ||| @enable_register, enable_byte>>)

    # Write CONTROL register (1 byte) with command bit set
    I2C.write(i2c, sensor, <<@command_bit ||| @control_register, control_byte>>)
  end

  def read(i2c, sensor, config) do
    # Read 4 bytes from ALS data registers (low and high) with command bit set
    <<ch0::little-16, ch1::little-16>> =
      I2C.write_read!(i2c, sensor, <<@command_bit ||| @als_data_register>>, 4)

    Config.to_lumens(config, ch0, ch1)
  end

  def read_raw(i2c, sensor) do
    # Read 4 bytes from ALS data registers (low and high) with command bit set
    <<ch0::little-16, ch1::little-16>> =
      I2C.write_read!(i2c, sensor, <<0x80 ||| 0x14>>, 4)

    {ch0, ch1}
  end
end
