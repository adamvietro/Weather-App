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
      # Example raw P, T, H
      raw = {415_148, 519_888, 33482}

      result = Converter.convert(raw, @calib)

      assert is_map(result)
      assert Map.has_key?(result, :temperature_c)
      assert Map.has_key?(result, :pressure_pa)
      assert Map.has_key?(result, :humidity_rh)

      # Rough expected ranges, not exact values
      assert_in_delta result.temperature_c, 20.0, 10.0
      assert_in_delta result.pressure_pa, 100_000.0, 5000.0
      assert_in_delta result.humidity_rh, 70.0, 20.0
    end
  end

  describe "convert/2 edge cases" do
    test "converts typical raw ADC values correctly" do
      # raw P, T, H
      raw = {415_148, 519_888, 33_482}

      result = Converter.convert(raw, @calib)

      assert is_map(result)
      assert Map.has_key?(result, :temperature_c)
      assert Map.has_key?(result, :pressure_pa)
      assert Map.has_key?(result, :humidity_rh)

      # Reasonable ranges based on calibration
      assert_in_delta result.temperature_c, 20.0, 10.0
      assert_in_delta result.pressure_pa, 100_000.0, 50_000.0
      assert_in_delta result.humidity_rh, 70.0, 20.0
    end

    test "caps humidity at 100%" do
      # Unrealistically high raw humidity
      raw = {415_148, 519_888, 100_000}
      result = Converter.convert(raw, @calib)
      assert result.humidity_rh <= 100.0
    end

    test "floors humidity at 0%" do
      # Raw humidity at zero
      raw = {415_148, 519_888, 0}
      result = Converter.convert(raw, @calib)
      assert result.humidity_rh >= 0.0
    end

    test "handles negative temperature values" do
      # Low raw temp value
      raw = {415_148, 0, 33482}
      result = Converter.convert(raw, @calib)
      assert result.temperature_c < 0.0
    end

    test "handles very high raw values without error" do
      raw = {1_000_000, 1_000_000, 100_000}
      result = Converter.convert(raw, @calib)

      assert result.temperature_c > -50.0
      assert result.pressure_pa > 500.0
      assert result.humidity_rh <= 100.0
    end

    test "handles very low raw values without error" do
      raw = {0, 0, 0}
      result = Converter.convert(raw, @calib)

      assert result.temperature_c < 50.0
      assert result.pressure_pa < 200_000.0
      assert result.humidity_rh >= 0.0
    end
  end

  describe "individual compensation functions" do
    test "temperature compensation returns a float and t_fine" do
      {temperature_c, t_fine} = Converter.compensate_temp(519_888, @calib)
      assert is_float(temperature_c)
      assert is_float(t_fine)
    end

    test "pressure compensation returns reasonable range" do
      t_fine = 28440
      pressure = Converter.compensate_press(415_148, t_fine, @calib)
      assert is_float(pressure)
      assert pressure > 0
    end

    test "humidity compensation returns 0..100" do
      t_fine = 28440
      humidity = Converter.compensate_hum(33_482, t_fine, @calib)
      assert is_float(humidity)
      assert humidity >= 0.0 and humidity <= 100.0
    end
  end
end
