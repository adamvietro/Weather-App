defmodule LTR390_UV.Config do
  import Bitwise

  @uv_sensitivity_base 2300.0

  defstruct resolution: :res_default,
            measure_rate: :measure_rate_100_ms,
            uvs_als: :uvs,
            gain: :low,
            reset: false

  def new, do: struct(__MODULE__)

  def new(opts) do
    struct(__MODULE__, opts)
  end

  defp resolution(:res_20bit), do: 0b000
  defp resolution(:res_19bit), do: 0b001
  defp resolution(:res_18bit), do: 0b010
  defp resolution(:res_17bit), do: 0b011
  defp resolution(:res_16bit), do: 0b100
  defp resolution(:res_15bit), do: 0b101
  defp resolution(:res_default), do: 0b010

  defp measure_rate(:measure_rate_25_ms), do: 0b000
  defp measure_rate(:measure_rate_50_ms), do: 0b001
  defp measure_rate(:measure_rate_100_ms), do: 0b010
  defp measure_rate(:measure_rate_200_ms), do: 0b011
  defp measure_rate(:measure_rate_500_ms), do: 0b100
  defp measure_rate(:measure_rate_1000_ms), do: 0b101
  defp measure_rate(:measure_rate_2000_ms), do: 0b110
  defp measure_rate(:measure_rate_default), do: 0b010

  defp gain(:min), do: 0b000
  defp gain(:low), do: 0b001
  defp gain(:med), do: 0b010
  defp gain(:high), do: 0b011
  defp gain(:max), do: 0b100
  defp gain(:gain_default), do: 0b001
  defp uvs_als(:uvs), do: 1
  defp uvs_als(:als), do: 0
  defp reset(true), do: 1
  defp reset(_), do: 0

  def to_control_byte(%__MODULE__{resolution: resolution, measure_rate: measure_rate}) do
    resolution(resolution) <<< 4 ||| measure_rate(measure_rate)
  end

  def to_gain_byte(%__MODULE__{gain: gain}) do
    gain(gain)
  end

  def to_enable_byte(%__MODULE__{uvs_als: uvs_als, reset: reset}) do
    reset_bit = reset(reset) <<< 4
    uvs_als_bit = uvs_als(uvs_als) <<< 3
    enable_bit = 1 <<< 1
    reserve_bit = 1 <<< 0

    reset_bit ||| uvs_als_bit ||| enable_bit ||| reserve_bit
  end

  defp integration_time_ms(:measure_rate_25_ms), do: 25
  defp integration_time_ms(:measure_rate_50_ms), do: 50
  defp integration_time_ms(:measure_rate_100_ms), do: 100
  defp integration_time_ms(:measure_rate_200_ms), do: 200
  defp integration_time_ms(:measure_rate_500_ms), do: 500
  defp integration_time_ms(:measure_rate_1000_ms), do: 1000
  defp integration_time_ms(:measure_rate_2000_ms), do: 2000
  defp integration_time_ms(:measure_rate_default), do: 100

  def gain_multiplier(:min), do: 1
  def gain_multiplier(:low), do: 3
  def gain_multiplier(:med), do: 6
  def gain_multiplier(:high), do: 9
  def gain_multiplier(:max), do: 18

  def als_to_lux(%{gain: gain, measure_rate: measure_rate}, raw_counts, wfac \\ 1.0) do
    int_ms = integration_time_ms(measure_rate)
    raw_counts * 0.6 / (gain_multiplier(gain) * (int_ms / 100)) * wfac
  end

  def uvs_to_uvi(%{gain: gain, measure_rate: measure_rate}, raw_counts, wfac \\ 1.0) do
    int_ms = integration_time_ms(measure_rate)
    sensitivity = @uv_sensitivity_base * (gain_multiplier(gain) / 18) * (int_ms / 400)
    raw_counts / sensitivity * wfac
  end
end
