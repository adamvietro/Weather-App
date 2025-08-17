defmodule TSL25911FN.ConfigTest do
  use ExUnit.Case, async: true
  alias TSL25911FN.Config

  @int_times [:it_100_ms, :it_200_ms, :it_300_ms, :it_400_ms, :it_500_ms, :it_600_ms, :it_default]
  @gains [:low, :med, :high, :max, :gain_default]

  describe "to_control_byte/1" do
    for gain <- @gains, int_time <- @int_times do
      test "gain #{gain} and int_time #{int_time}" do
        config = %Config{gain: unquote(gain), int_time: unquote(int_time)}
        byte = Config.to_control_byte(config)

        # Just assert it returns an integer in 0..255 range
        assert is_integer(byte)
        assert byte >= 0 and byte <= 0xFF
      end
    end
  end

  describe "to_enable_byte/1" do
    for shutdown <- [true, false], interrupt <- [true, false] do
      test "shutdown #{shutdown} and interrupt #{interrupt}" do
        config = %Config{shutdown: unquote(shutdown), interrupt: unquote(interrupt)}
        byte = Config.to_enable_byte(config)

        # Returns an integer in 0..255
        assert is_integer(byte)
        assert byte >= 0 and byte <= 0xFF
      end
    end
  end

  describe "to_lumens/3" do
    test "calculates lux for supported int_time/gain combos" do
      ch0 = 500
      ch1 = 100

      for int_time <- @int_times -- [:it_default],
          gain <- @gains -- [:gain_default] do
        config = %{int_time: int_time, gain: gain}

        lux = Config.to_lumens(config, ch0, ch1)
        # Lux should be non-negative
        assert is_float(lux)
        assert lux >= 0.0
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
