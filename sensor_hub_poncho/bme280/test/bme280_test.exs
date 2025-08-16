# test/bme280_test.exs
defmodule Bme280Test do
  use ExUnit.Case

  alias Bme280
  alias Bme280.Calibration

  setup do
    # Mocked I2C data
    fake_calibration = %Calibration{
      dig_T1: 28318,
      dig_T2: 26374,
      dig_T3: 50,
      dig_P1: 35877,
      dig_P2: -10591,
      dig_P3: 3024,
      dig_P4: 7243,
      dig_P5: -67,
      dig_P6: -7,
      dig_P7: 11700,
      dig_P8: -11800,
      dig_P9: 5000,
      dig_H1: 75,
      dig_H2: 375,
      dig_H3: 0,
      dig_H4: 289,
      dig_H5: 48,
      dig_H6: 30
    }

    fake_raw = {358_320, 547_280, 23282}

    {:ok, state} =
      Bme280.start_link(%{
        address: 0x76,
        i2c_bus_name: "i2c-1",
        mode: :normal,
        osrs_t: :x1,
        osrs_p: :x1,
        osrs_h: :x1
      })

    {:ok, %{state: state, fake_calibration: fake_calibration, fake_raw: fake_raw}}
  end

  # test "returns calibration struct", %{fake_calibration: fake_calibration} do
  #   # We'll assume the GenServer has a mocked calibration for the test
  #   calib = Bme280.read_calibration()
  #   assert %Calibration{} = calib
  #   assert calib.dig_T1 == 28318
  # end

  # test "returns last raw reading initially :no_reading" do
  #   reading = Bme280.read()
  #   assert reading.raw_reading == :no_reading
  # end

  # test "updates last_raw_reading after handle_info", %{fake_raw: fake_raw} do
  #   # Simulate handle_info call manually
  #   send(Bme280, :measure)
  #   # give GenServer a moment
  #   :timer.sleep(10)

  #   reading = Bme280.read()
  #   assert reading.raw_reading == fake_raw
  # end

  # test "converts raw reading to human units", %{fake_raw: raw, fake_calibration: calib} do
  #   converted = Bme280.Converter.convert(raw, calib)
  #   assert is_float(converted.temperature_c)
  #   assert is_float(converted.pressure_pa)
  #   assert is_float(converted.humidity_rh)
  # end
end
