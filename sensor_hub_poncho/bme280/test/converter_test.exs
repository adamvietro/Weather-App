defmodule Bme280.ConverterTest do
  use ExUnit.Case, async: true
  alias Bme280.{Converter, Calibration}

  # Example calibration struct (values from datasheet example or arbitrary but consistent)
  @calib %Calibration{
    dig_T1: 27504,
    dig_T2: 26435,
    dig_T3: -1000,
    dig_P1: 36477,
    dig_P2: -10685,
    dig_P3: 3024,
    dig_P4: 2855,
    dig_P5: 140,
    dig_P6: -7,
    dig_P7: 15500,
    dig_P8: -14600,
    dig_P9: 6000,
    dig_H1: 75,
    dig_H2: 362,
    dig_H3: 0,
    dig_H4: 315,
    dig_H5: 50,
    dig_H6: 30
  }

  describe "convert/2" do
    test "converts raw ADC values into meaningful readings" do
      raw = {415148, 519888, 33482} # Example raw P, T, H

      result = Converter.convert(raw, @calib)

      assert is_map(result)
      assert Map.has_key?(result, :temperature_c)
      assert Map.has_key?(result, :pressure_pa)
      assert Map.has_key?(result, :humidity_rh)

      # Rough expected ranges, not exact values
      assert_in_delta result.temperature_c, 20.0, 10.0
      assert_in_delta result.pressure_pa, 100_000.0, 5000.0
      assert_in_delta result.humidity_rh, 30.0, 20.0
    end
  end
end
