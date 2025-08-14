defmodule TSL25911FN.ConfigTest do
  use ExUnit.Case, async: true

  alias TSL25911FN.Config

  @int_times [:it_100_ms, :it_200_ms, :it_300_ms, :it_400_ms, :it_500_ms, :it_600_ms, :it_default]
  @gains [:low, :med, :high, :max, :gain_default]

  describe "to_control_byte/1" do
    for gain <- @gains, int_time <- @int_times do
      test "gain #{gain} and int_time #{int_time}" do
        config = %Config{gain: unquote(gain), int_time: unquote(int_time)}

        expected =
          Config.send(:gain, config.gain) <<< 4 ||| Config.send(:int_time, config.int_time)

        actual = Config.to_control_byte(config)

        assert actual == expected
      end
    end
  end

  describe "to_enable_byte/1" do
    for shutdown <- [true, false], interrupt <- [true, false] do
      test "shutdown #{shutdown} and interrupt #{interrupt}" do
        config = %Config{shutdown: unquote(shutdown), interrupt: unquote(interrupt)}

        interrupt_bit = if interrupt, do: 1 <<< 4, else: 0
        als_enable_bit = 1 <<< 1
        power_on_bit = 1 <<< 0
        shutdown_bit = if shutdown, do: 1, else: 0

        expected = interrupt_bit ||| als_enable_bit ||| power_on_bit ||| shutdown_bit
        actual = Config.to_enable_byte(config)

        assert actual == expected
      end
    end
  end

  describe "to_lumens/3" do
    test "calculates lux for all supported int_time/gain combos" do
      ch0 = 500
      ch1 = 100

      for int_time <- @int_times -- [:it_default],
          gain <- @gains -- [:gain_default] do
        config = %{int_time: int_time, gain: gain}
        factor = Map.fetch!(Config.@(to_lumens_factor, {int_time, gain}))
        expected_lux = max((ch0 - ch1) * factor, 0.0)
        actual_lux = Config.to_lumens(config, ch0, ch1)

        assert_in_delta actual_lux, expected_lux, 0.0001
      end
    end

    test "raises on unsupported int_time/gain combos" do
      config = %{int_time: :unsupported_time, gain: :low}

      assert_raise ArgumentError, ~r/Unsupported integration_time\/gain combination/, fn ->
        Config.to_lumens(config, 100, 50)
      end
    end
  end
end
