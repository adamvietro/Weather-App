defmodule LTR390_UV.ConfigTest do
  use ExUnit.Case, async: true

  alias LTR390_UV.Config

  @raw_counts 1000
  @weight_factor 1.0

  @gains [:min, :low, :med, :high, :max]
  @measure_rates [
    :measure_rate_25_ms,
    :measure_rate_50_ms,
    :measure_rate_100_ms,
    :measure_rate_200_ms,
    :measure_rate_500_ms,
    :measure_rate_1000_ms,
    :measure_rate_2000_ms
  ]

  @uv_sensitivity_base 2300.0

  # Helper to replicate integration_time_ms from private
  defp integration_time_ms(rate) do
    case rate do
      :measure_rate_25_ms -> 25
      :measure_rate_50_ms -> 50
      :measure_rate_100_ms -> 100
      :measure_rate_200_ms -> 200
      :measure_rate_500_ms -> 500
      :measure_rate_1000_ms -> 1000
      :measure_rate_2000_ms -> 2000
      _ -> 100
    end
  end

  # Helper to replicate gain_multiplier from private
  defp gain_multiplier(gain) do
    case gain do
      :min -> 1
      :low -> 3
      :med -> 6
      :high -> 9
      :max -> 18
      _ -> 3
    end
  end

  describe "als_to_lux/3" do
    for gain <- @gains, measure_rate <- @measure_rates do
      test "gain #{gain} and measure_rate #{measure_rate}" do
        config = %{gain: unquote(gain), measure_rate: unquote(measure_rate)}
        raw_counts = @raw_counts
        wfac = @weight_factor

        int_ms = integration_time_ms(config.measure_rate)
        gain_mult = gain_multiplier(config.gain)
        expected = raw_counts * 0.6 / (gain_mult * (int_ms / 100)) * wfac

        actual = Config.als_to_lux(config, raw_counts, wfac)

        assert_in_delta actual, expected, 0.0001
      end
    end
  end

  describe "uvs_to_uvi/3" do
    for gain <- @gains, measure_rate <- @measure_rates do
      test "gain #{gain} and measure_rate #{measure_rate}" do
        config = %{gain: unquote(gain), measure_rate: unquote(measure_rate)}
        raw_counts = @raw_counts
        wfac = @weight_factor

        int_ms = integration_time_ms(config.measure_rate)
        gain_mult = gain_multiplier(config.gain)
        sensitivity = @uv_sensitivity_base * (gain_mult / 18) * (int_ms / 400)
        expected = raw_counts / sensitivity * wfac

        actual = Config.uvs_to_uvi(config, raw_counts, wfac)

        assert_in_delta actual, expected, 0.0001
      end
    end
  end
end
