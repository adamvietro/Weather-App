# SGP40 Indoor Air Quality Sensor

**Sgp40** is an Elixir GenServer module for interacting with the **SGP40 VOC sensor** over **I2C**. It provides real-time air quality measurements, decoded from raw sensor readings, and is designed to be integrated into a larger sensor hub or firmware project.

---

## Features

- Simple **start_link** interface with optional configuration
- Automatic I2C sensor initialization
- Periodic VOC measurement scheduling
- VOC measurement decoding with **CRC-8 check**
- Easy retrieval of the last reading with `get_measurement/0`
- Clean termination with I2C cleanup

## Installation

### 1. Add the SGP40 sensor dependency

Add the `sgp40` app to your `mix.exs` dependencies:

```elixir
defp deps do
  [
    {:sgp40, path: "../sgp40"}, # Adjust path if using umbrella or sensor hub structure
    {:circuits_i2c, "~> 1.1"}
  ]
end
```

#### Then fetch the dependencies
```bash
mix deps.get
```

## Usage

After adding the dependency and starting the sensor, you can interact with it via `Sgp40` module functions.

### Starting the Sensor

The sensor can be started with defaults (I2C bus `"i2c-1"` and address `0x59`):

```elixir
{:ok, pid} = Sgp40.start_link()
```

#### Taking Measurements

The sensor automatically measures periodically after startup, but you can manually trigger a measurement:

```elixir
Sgp40.measure()
```

#### Reading Mesurements

``` elixir
Sgp40.get_measurement()
```