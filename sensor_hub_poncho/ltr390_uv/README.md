# LTR390_UV Elixir Module

This Elixir module allows you to interface with the **LTR390 UV/ALS sensor** over I2C, read raw and scaled UV and ambient light (ALS) values, and convert them to UV index and lux.

---

## Features

- Configure the sensor’s resolution, measurement rate, gain, and mode (ALS or UVS)  
- Read raw sensor counts for UV and ALS  
- Convert raw counts to **UV index** and **lux** using standard formulas  
- Works with `Circuits.I2C` on Raspberry Pi and other compatible boards  

---

## Installation

Add the module to your project and ensure `circuits_i2c` is added to your `mix.exs` dependencies:

defp deps do
  [
    {:circuits_i2c, "~> 1.0"}
  ]
end

Then run:

mix deps.get

---

## Usage

### Start the sensor

alias LTR390_UV, as: LTR

{:ok, _pid} = LTR.start_link()

### Get measurements

# Get scaled values
{lux, uv_index} = LTR.get_measurement()
IO.puts("Ambient Light (lux): #{lux}")
IO.puts("UV Index: #{uv_index}")

### Example Output

{0.0, 18.4}      # Low light / low UV
{0.02, 295.6}    # Slightly brighter UV reading

### Configure sensor

You can adjust the `Config` struct to change resolution, gain, measurement rate, and mode:

config = LTR390_UV.Config.new(gain: :med, measure_rate: :measure_rate_100_ms, uvs_als: :uvs)
LTR.write_config(config)

---

## Notes

- Ensure your I2C bus is enabled on your board (e.g., `i2c-1` on Raspberry Pi)  
- Wait at least the measurement time between readings (default 100ms) for accurate data  
- Raw readings can be accessed before conversion if needed for debugging  

---

## License

This code is released under the MIT License.
