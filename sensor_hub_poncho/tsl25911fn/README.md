# TSL25911FN Elixir Module

**TSL25911FN** is an Elixir module for interfacing with the **TSL25911FN Light Sensor** over I2C. It allows you to read **raw ALS values**, convert them to **lumens**, and configure the sensor's gain and integration time.

## Features
- Configure **gain** and **integration time**
- Read **raw ALS values**
- Convert raw counts to **lumens**
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

Copy the `TSL25911FN` module files into your project.

## Usage

### Start the Sensor

```elixir
alias TSL25911FN, as: TSL
{:ok, _pid} = TSL.start_link(address: 0x29, i2c_bus_name: "i2c-1")
```

### Get Measurements

```elixir
{ch0, ch1} = TSL.get_measurement()
lux = TSL.measure()
IO.puts("Lux: #{lux}")
```

Example Output:

```
Lux: 123.4
```

### Configure Sensor

```elixir
config = TSL25911FN.Config.new(
  gain: :high,
  int_time: :it_100_ms,
  shutdown: false,
  interrupt: false
)
TSL25911FN.Comm.write_config(config, i2c, address)
```

### Using Raw Reads

```elixir
i2c = TSL25911FN.Comm.open("i2c-1")
sensor = TSL25911FN.Comm.discover()
raw_data = TSL25911FN.Comm.read_raw(i2c, sensor)
IO.inspect(raw_data)
```

This will return a tuple with the raw channel readings:

```
{ch0, ch1}
```

The **TSL25911FN.Config.to_lumens/3** function can then be used to convert these raw readings into lux:

```elixir
lux = TSL25911FN.Config.to_lumens(config, ch0, ch1)
IO.puts("Lux: #{lux}")
```

## Notes
- Ensure the I2C bus is enabled on your board.
- Adjust **gain** and **integration time** depending on the expected light levels for better precision.
- The sensor updates readings at the configured integration time, so allow enough time between reads.
