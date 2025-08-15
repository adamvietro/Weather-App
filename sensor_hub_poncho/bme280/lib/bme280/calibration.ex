defmodule Bme280.Calibration do
  alias Circuits.I2C
  import Bitwise

  defstruct [
    :dig_T1,
    :dig_T2,
    :dig_T3,
    :dig_P1,
    :dig_P2,
    :dig_P3,
    :dig_P4,
    :dig_P5,
    :dig_P6,
    :dig_P7,
    :dig_P8,
    :dig_P9,
    :dig_H1,
    :dig_H2,
    :dig_H3,
    :dig_H4,
    :dig_H5,
    :dig_H6
  ]

  @temp_press_start 0x88
  # 0x88..0xA1
  @temp_press_len 26
  @hum_start 0xE1
  # 0xE1..0xE7
  @hum_len 7

  def read_all(i2c, sensor) do
    # Read temperature & pressure calibration (0x88..0xA0 = 25 bytes)
    t_p_data =
      I2C.write_read!(i2c, sensor, <<@temp_press_start>>, @temp_press_len)
      |> ensure_binary()

    <<
      dig_T1_lsb,
      dig_T1_msb,
      dig_T2_lsb,
      dig_T2_msb,
      dig_T3_lsb,
      dig_T3_msb,
      dig_P1_lsb,
      dig_P1_msb,
      dig_P2_lsb,
      dig_P2_msb,
      dig_P3_lsb,
      dig_P3_msb,
      dig_P4_lsb,
      dig_P4_msb,
      dig_P5_lsb,
      dig_P5_msb,
      dig_P6_lsb,
      dig_P6_msb,
      dig_P7_lsb,
      dig_P7_msb,
      dig_P8_lsb,
      dig_P8_msb,
      dig_P9_lsb,
      dig_P9_msb,
      _reserved,
      dig_H1
    >> = t_p_data

    # Read humidity calibration (0xE1..0xE7 = 7 bytes)
    h_data =
      I2C.write_read!(i2c, sensor, <<@hum_start>>, @hum_len)
      |> ensure_binary()

    <<dig_H2_lsb, dig_H2_msb, dig_H3, h4_lsb, h4_msb_bits, h5_msb_bits, dig_H6>> = h_data

    %__MODULE__{
      dig_T1: dig_T1_msb <<< 8 ||| dig_T1_lsb,
      dig_T2: signed(dig_T2_msb <<< 8 ||| dig_T2_lsb),
      dig_T3: signed(dig_T3_msb <<< 8 ||| dig_T3_lsb),
      dig_P1: dig_P1_msb <<< 8 ||| dig_P1_lsb,
      dig_P2: signed(dig_P2_msb <<< 8 ||| dig_P2_lsb),
      dig_P3: signed(dig_P3_msb <<< 8 ||| dig_P3_lsb),
      dig_P4: signed(dig_P4_msb <<< 8 ||| dig_P4_lsb),
      dig_P5: signed(dig_P5_msb <<< 8 ||| dig_P5_lsb),
      dig_P6: signed(dig_P6_msb <<< 8 ||| dig_P6_lsb),
      dig_P7: signed(dig_P7_msb <<< 8 ||| dig_P7_lsb),
      dig_P8: signed(dig_P8_msb <<< 8 ||| dig_P8_lsb),
      dig_P9: signed(dig_P9_msb <<< 8 ||| dig_P9_lsb),
      dig_H1: dig_H1,
      dig_H2: signed(dig_H2_msb <<< 8 ||| dig_H2_lsb),
      dig_H3: dig_H3,
      dig_H4: signed(h4_lsb <<< 4 ||| (h4_msb_bits &&& 0x0F)),
      dig_H5: signed((h5_msb_bits &&& 0xF0) >>> 4 ||| h5_msb_bits <<< 4),
      dig_H6: signed(dig_H6)
    }
  end

  defp signed(value) when value > 0x7FFF, do: value - 0x10000
  defp signed(value), do: value

  # Convert list to binary if needed
  defp ensure_binary(data) when is_list(data), do: :erlang.list_to_binary(data)
  defp ensure_binary(data) when is_binary(data), do: data
end
