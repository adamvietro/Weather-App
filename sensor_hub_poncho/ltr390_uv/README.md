# LTR390_UV Elixir Module

**LTR390_UV** is an Elixir module for interfacing with the **LTR390 UV and Ambient Light Sensor** over I2C. It allows you to read **raw UV and ALS values**, convert them to **UV Index and Lux**, and configure the sensor's gain, resolution, and measurement rate.

## Features
- Configure **gain**, **resolution**, and **measurement rate**
- Read **raw ALS and UVS values**
- Convert raw counts to **UV Index** and **Lux**
- Works with **Circuits.I2C** on Raspberry Pi or other compatible boards

## Installation
Add `circuits_i2c` to your dependencies in `mix.exs`:

```elixir
defp deps do
  [
    {:circuits_i2c, "~> 1.0"}
  ]
end
```

Then fetch dependencies:

```bash
mix deps.get
```

Copy the `LTR390_UV` module files into your project.

## Usage

### Start the Sensor

```elixir
alias LTR390_UV, as: LTR
{:ok, _pid} = LTR.start_link()
```

### Get Measurements

```elixir
{uv_index, lux} = LTR.get_measurement()
IO.puts("UV Index: #{uv_index}")
IO.puts("Ambient Light (lux): #{lux}")
```

Example Output:

```
UV Index: 0.02
Ambient Light (lux): 295.6
```

### Configure Sensor

```elixir
config = LTR390_UV.Config.new(
  gain: :high,
  resolution: :res_18bit,
  measure_rate: :measure_rate_100_ms,
  uvs_als: :uvs
)
LTR.write_config(config)
```

### Using Raw Reads

```elixir
i2c = LTR390_UV.Comm.open("i2c-1")
sensor = LTR390_UV.Comm.discover()
raw_als = LTR390_UV.Comm.read(i2c, sensor, %LTR390_UV.Config{uvs_als: :als})
raw_uvs = LTR390_UV.Comm.read(i2c, sensor, %LTR390_UV.Config{uvs_als: :uvs})
```

## Notes
- Ensure your sensor has enough time between measurements according to the **measure_rate**.
- Raw counts can be converted to standard units using `LTR390_UV.Config.als_to_lux/3` and `LTR390_UV.Config.uvs_to_uvi/3`.
- Works on Raspberry Pi and other boards compatible with I2C and `Circuits.I2C`.
