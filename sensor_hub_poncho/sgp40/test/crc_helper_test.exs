defmodule Sgp40.CrcHelperTest do
  use ExUnit.Case
  alias Sgp40.CrcHelper

  import Bitwise

  describe "crc8/1" do
    test "computes CRC for a binary correctly" do
      data = <<0xBE, 0xEF>>
      # replace with correct expected value from manual calculation
      expected_crc = 0x92
      assert CrcHelper.crc8(data) == expected_crc
    end

    test "computes CRC for a list of bytes correctly" do
      data = [0xBE, 0xEF]
      # replace with correct expected value
      expected_crc = 0x92
      assert CrcHelper.crc8(data) == expected_crc
    end
  end

  describe "encode_with_crc/1" do
    test "encodes two bytes with CRC" do
      msb = 0xBE
      lsb = 0xEF
      <<b1, b2, crc>> = CrcHelper.encode_with_crc({msb, lsb})
      assert b1 == msb
      assert b2 == lsb
      assert crc == CrcHelper.crc8(<<msb, lsb>>)
    end
  end

  describe "decode_voc/1" do
    test "decodes a valid raw measurement to VOC ppb" do
      msb = 0x12
      lsb = 0x34
      crc = CrcHelper.crc8(<<msb, lsb>>)
      raw_bytes = <<msb, lsb, crc, 0xFF, 0xFF, 0xFF>>
      {:ok, voc} = CrcHelper.decode_voc(raw_bytes)
      expected = (msb <<< 8 ||| lsb) * 500 / 65_535
      assert_in_delta voc, expected, 0.0001
    end

    test "returns error on CRC mismatch" do
      msb = 0x12
      lsb = 0x34
      # incorrect CRC
      crc = 0x00
      raw_bytes = <<msb, lsb, crc, 0xFF, 0xFF, 0xFF>>
      assert CrcHelper.decode_voc(raw_bytes) == {:error, :crc_mismatch}
    end
  end
end
