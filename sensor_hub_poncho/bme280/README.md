# BME280 Sensor Module for Elixir

This Elixir module provides a complete interface for reading temperature, pressure, and humidity from the **BME280 sensor**. It includes compensation functions based on the sensor's calibration data and converts raw ADC readings into meaningful physical values.

---

## Features

- Reads raw ADC values from the BME280 sensor
- Compensates temperature, pressure, and humidity using calibration data
- Converts raw values into:
  - Temperature in °C
  - Pressure in Pa
  - Relative Humidity in %
- Handles edge cases including very high or low sensor readings
- Fully tested with **ExUnit** tests

---

## Installation

Add the `bme280` app to your Elixir project:

```elixir
def deps do
  [
    {:bme280, path: "path_to_bme280_module"}
  ]
end

## Usage

### Initializing Calibration Data

The module requires a calibration struct. Example:

```elixir
alias Bme280.Calibration

calib = %Calibration{
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

### Converting Raw ADC Values

The `Converter.convert/2` function takes raw ADC readings from the BME280 sensor and the calibration struct, then returns meaningful values for temperature, pressure, and humidity.

**Example:**

```elixir
alias Bme280.{Converter, Calibration}

calib = %Calibration{
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

raw = {415_148, 519_888, 33_482}
result = Converter.convert(raw, calib)

IO.inspect(result)
# => %{temperature_c: 25.08, pressure_pa: 128422.28, humidity_rh: 70.0}
