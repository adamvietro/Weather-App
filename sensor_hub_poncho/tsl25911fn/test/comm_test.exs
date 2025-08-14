defmodule TSL25911FN.CommTest do
  use ExUnit.Case, async: true

  alias TSL25911FN.Comm
  alias TSL25911FN.Config

  # Sample config for tests
  @sample_config %Config{gain: :max, int_time: :it_100_ms, shutdown: false, interrupt: false}

  describe "discover/1" do
    test "calls Circuits.I2C.discover_one! with default addresses" do
      # Here you would mock Circuits.I2C.discover_one!/1 to return a known address
      # Example:
      # expect Circuits.I2C to be called with [0x29]
      # assert returned address is what you mocked
    end
  end

  describe "open/1" do
    test "calls Circuits.I2C.open and returns {:ok, pid}" do
      # Mock Circuits.I2C.open/1 to return {:ok, fake_pid}
      # Assert that open returns the i2c pid as expected
    end
  end

  describe "write_config/3" do
    test "writes enable and control bytes to correct registers" do
      # Mock I2C.write/3 and assert it is called with correct register and bytes
      # Use Config.to_enable_byte and to_control_byte to get expected bytes
    end
  end

  describe "read/3" do
    test "reads ALS data and converts using Config.to_lumens" do
      # Mock I2C.write_read!/4 to return 4 bytes
      # Assert that the returned value is correct per Config.to_lumens
    end
  end

  describe "read_raw/2" do
    test "reads raw ALS data and returns two 16-bit values" do
      # Mock I2C.write_read!/4 to return 4 bytes
      # Assert it returns a tuple {ch0, ch1} as expected
    end
  end
end
