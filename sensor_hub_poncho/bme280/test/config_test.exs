defmodule Bme280.ConfigTest do
  use ExUnit.Case, async: true
  alias Bme280.Config

  describe "to_ctrl_hum_byte/1" do
    test "encodes humidity oversampling correctly" do
      cfg = %Config{osrs_h: :osrs_1x}
      assert Config.to_ctrl_hum_byte(cfg) == 0b001

      cfg = %Config{osrs_h: :osrs_16x}
      assert Config.to_ctrl_hum_byte(cfg) == 0b101
    end
  end

  describe "to_ctrl_meas_byte/1" do
    test "encodes temperature, pressure, and mode correctly" do
      cfg = %Config{osrs_t: :osrs_2x, osrs_p: :osrs_4x, mode: :normal}
      # Expected bits: osrs_t=010 <<5 = 01000000, osrs_p=011 <<2 = 00001100, mode=11
      assert Config.to_ctrl_meas_byte(cfg) == 0b01001111
    end
  end

  describe "to_config_byte/1" do
    test "encodes standby, filter, spi correctly" do
      cfg = %Config{
        standby_time: :standby_250_ms,
        filter: :filter_8,
        spi3w_en: true
      }

      # standby=011 <<5 = 01100000
      # filter=011 <<2 = 00001100
      # spi=1
      assert Config.to_config_byte(cfg) == 0b01101101
    end
  end

  describe "integration_ms/1" do
    test "computes integration time correctly in normal mode" do
      cfg = %Config{
        mode: :normal,
        osrs_t: :osrs_2x,
        osrs_p: :osrs_16x,
        osrs_h: :osrs_1x,
        standby_time: :standby_125_ms
      }

      # oversampling times: 2 + 16 + 1 = 19, + base=1 = 20
      # standby=125, total=145
      assert Config.integration_ms(cfg) == 145
    end

    test "computes integration time correctly in forced mode (no standby)" do
      cfg = %Config{
        mode: :forced,
        osrs_t: :osrs_1x,
        osrs_p: :osrs_1x,
        osrs_h: :osrs_1x
      }

      # 1 + 1 + 1 + 1 = 4 ms
      assert Config.integration_ms(cfg) == 4
    end
  end
end
0110111
