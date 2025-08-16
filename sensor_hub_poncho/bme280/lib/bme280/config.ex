defmodule Bme280.Config do
  import Bitwise

  defstruct mode: :normal,
            osrs_t: :osrs_2x,
            osrs_p: :osrs_16x,
            osrs_h: :osrs_1x,
            standby_time: :standby_0_5_ms,
            filter: :filter_16,
            spi3w_en: false

  def new, do: struct(__MODULE__)

  def new(opts) do
    struct(__MODULE__, opts)
  end

  @doc """
  This will be responsible for the: Humidity oversampling.
  """
  def to_ctrl_hum_byte(%__MODULE__{osrs_h: osrs_h}) do
    osrs_h_bit = osrs_h_to_bit(osrs_h)
    0b00000000 ||| osrs_h_bit
  end

  @doc """
  This will be responsible for the: Pressure oversampling, Temperature oversampling and
  the Mode that the sensor is currently operating in.
  """
  def to_ctrl_meas_byte(%__MODULE__{osrs_t: osrs_t, osrs_p: osrs_p, mode: mode}) do
    osrs_t_bit = osrs_t_to_bit(osrs_t)
    osrs_p_bit = osrs_p_to_bit(osrs_p)
    mode_bit = mode_to_bit(mode)
    0b00000000 ||| osrs_t_bit <<< 5 ||| osrs_p_bit <<< 2 ||| mode_bit
  end

  @doc """
  This will be responsable for the: filtering, standby time and SPI 3-wire mode.
  """
  def to_config_byte(%__MODULE__{standby_time: standby_time, filter: filter, spi3w_en: spi3w_en}) do
    standby_time_bit = standby_time_to_bit(standby_time)
    filter_bit = filter_to_bit(filter)
    spi3w_en_bit = spi3w_en_bit(spi3w_en)

    0b00000000 ||| standby_time_bit ||| filter_bit ||| spi3w_en_bit
  end

  defp osrs_h_to_bit(:osrs_1x), do: 0b001
  defp osrs_h_to_bit(:osrs_2x), do: 0b010
  defp osrs_h_to_bit(:osrs_4x), do: 0b011
  defp osrs_h_to_bit(:osrs_8x), do: 0b100
  defp osrs_h_to_bit(:osrs_16x), do: 0b101

  defp standby_time_to_bit(:standby_0_5_ms), do: 0b000
  defp standby_time_to_bit(:standby_62_5_ms), do: 0b001
  defp standby_time_to_bit(:standby_125_ms), do: 0b010
  defp standby_time_to_bit(:standby_250_ms), do: 0b011
  defp standby_time_to_bit(:standby_500_ms), do: 0b100
  defp standby_time_to_bit(:standby_1000_ms), do: 0b101
  defp standby_time_to_bit(:standby_10_ms), do: 0b110
  defp standby_time_to_bit(:standby_20_ms), do: 0b111

  defp filter_to_bit(:filter_off), do: 0b000
  defp filter_to_bit(:filter_2), do: 0b001
  defp filter_to_bit(:filter_4), do: 0b010
  defp filter_to_bit(:filter_8), do: 0b011
  defp filter_to_bit(:filter_16), do: 0b100

  defp spi3w_en_bit(false), do: 0b0
  defp spi3w_en_bit(true), do: 0b1

  defp osrs_t_to_bit(:osrs_1x), do: 0b001
  defp osrs_t_to_bit(:osrs_2x), do: 0b010
  defp osrs_t_to_bit(:osrs_4x), do: 0b011
  defp osrs_t_to_bit(:osrs_8x), do: 0b100
  defp osrs_t_to_bit(:osrs_16x), do: 0b101

  defp osrs_p_to_bit(:osrs_1x), do: 0b001
  defp osrs_p_to_bit(:osrs_2x), do: 0b010
  defp osrs_p_to_bit(:osrs_4x), do: 0b011
  defp osrs_p_to_bit(:osrs_8x), do: 0b100
  defp osrs_p_to_bit(:osrs_16x), do: 0b101

  defp mode_to_bit(:normal), do: 0b00
  defp mode_to_bit(:forced), do: 0b01
  defp mode_to_bit(:sleep), do: 0b10

  @doc """
  This will be responsible for calculating the integration time in milliseconds.
  """
  @spec integration_ms(%__MODULE__{}) :: non_neg_integer()
  def integration_ms(%__MODULE__{
        mode: mode,
        osrs_t: osrs_t,
        osrs_p: osrs_p,
        osrs_h: osrs_h,
        standby_time: standby_time
      }) do
    # Convert oversampling atoms to approximate times in ms
    t = osrs_to_ms(osrs_t)
    p = osrs_to_ms(osrs_p)
    h = osrs_to_ms(osrs_h)

    # Base measurement overhead (ms)
    base = 1

    # Standby time (ms)
    standby_ms =
      case mode do
        :normal -> standby_time_to_ms(standby_time)
        _ -> 0
      end

    # Total integration time
    total = t + p + h + base + standby_ms

    # Always round up to the nearest integer
    max(1, round(total))
  end

  defp osrs_to_ms(:osrs_skip), do: 0
  defp osrs_to_ms(:osrs_1x), do: 1
  defp osrs_to_ms(:osrs_2x), do: 2
  defp osrs_to_ms(:osrs_4x), do: 4
  defp osrs_to_ms(:osrs_8x), do: 8
  defp osrs_to_ms(:osrs_16x), do: 16

  defp standby_time_to_ms(:standby_0_5_ms), do: 1
  defp standby_time_to_ms(:standby_10_ms), do: 10
  defp standby_time_to_ms(:standby_20_ms), do: 20
  defp standby_time_to_ms(:standby_62_5_ms), do: 63
  defp standby_time_to_ms(:standby_125_ms), do: 125
  defp standby_time_to_ms(:standby_250_ms), do: 250
  defp standby_time_to_ms(:standby_500_ms), do: 500
  defp standby_time_to_ms(:standby_1000_ms), do: 1000
end
