# defmodule LTR390_UV.CommTest do
#   use ExUnit.Case, async: true

#   alias LTR390_UV.{Comm, Config}

#   defmodule MockI2C do
#     def write(_i2c, _sensor, <<0x80 ||| 0x00, byte>>) do
#       send(self(), {:write, :enable_register, byte})
#       :ok
#     end

#     def write(_i2c, _sensor, <<0x80 ||| 0x04, byte>>) do
#       send(self(), {:write, :control_register, byte})
#       :ok
#     end

#     def write(_i2c, _sensor, <<0x80 ||| 0x05, byte>>) do
#       send(self(), {:write, :gain_register, byte})
#       :ok
#     end

#     def write_read!(_i2c, _sensor, <<0x80 ||| 0x10>>, 3) do
#       # Simulate UVS data: bytes low, mid, high
#       <<0xAA, 0xBB, 0xCC>>
#     end

#     def write_read!(_i2c, _sensor, <<0x80 ||| 0x0D>>, 3) do
#       # Simulate ALS data: bytes low, mid, high
#       <<0x11, 0x22, 0x33>>
#     end
#   end

#   setup do
#     config = Config.new()
#     {:ok, config: config}
#   end

#   test "write_config writes correct bytes", %{config: config} do
#     i2c = :dummy_i2c
#     sensor = 0x53

#     assert :ok = Comm.write_config(MockI2C, config, i2c, sensor)

#     assert_received {:write, :enable_register, enable_byte}
#     assert_received {:write, :control_register, control_byte}
#     assert_received {:write, :gain_register, gain_byte}

#     assert is_integer(enable_byte)
#     assert is_integer(control_byte)
#     assert is_integer(gain_byte)
#   end

#   test "read uvs returns correct uvi", %{config: config} do
#     i2c = :dummy_i2c
#     sensor = 0x53

#     config = %{config | uvs_als: :uvs}

#     uvi = Comm.read(MockI2C, i2c, sensor, config)
#     assert is_float(uvi)
#   end

#   test "read als returns correct lux", %{config: config} do
#     i2c = :dummy_i2c
#     sensor = 0x53

#     config = %{config | uvs_als: :als}

#     lux = Comm.read(MockI2C, i2c, sensor, config)
#     assert is_float(lux)
#   end
# end
