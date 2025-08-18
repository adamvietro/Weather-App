defmodule Sgp40.CrcHelper do
  import Bitwise

  @moduledoc """
  CRC-8 calculation for SGP40 (polynomial 0x31)
  """

  @polynomial 0x31
  @init 0xFF

  @doc """
  Calculate the CRC-8 of a binary or list of bytes
  """
  def crc8(data) when is_binary(data), do: crc8(:binary.bin_to_list(data))

  def crc8(data) when is_list(data) do
    Enum.reduce(data, @init, fn byte, crc ->
      crc_byte(Bitwise.^^^(crc, byte))
    end)
  end

  # Process one byte through CRC
  defp crc_byte(byte) do
    Enum.reduce(0..7, byte, fn _, crc ->
      if (crc &&& 0x80) != 0 do
        Bitwise.^^^(crc <<< 1, @polynomial) &&& 0xFF
      else
        crc <<< 1 &&& 0xFF
      end
    end)
  end

  @doc """
  Encode a 2-byte word + CRC as required by the sensor
  Expects {msb, lsb} tuple
  """
  def encode_with_crc({msb, lsb}) do
    data = <<msb, lsb>>
    <<msb, lsb, crc8(data)>>
  end

  @doc """
  Convert raw SGP40 measurement (6 bytes) to VOC value in ppb.
  Expects <<msb, lsb, crc, _, _, _>> from get_measurement/0
  """
  def decode_voc(<<msb, lsb, crc, _, _, _>>) do
    if crc != crc8(<<msb, lsb>>) do
      {:error, :crc_mismatch}
    else
      raw = msb <<< 8 ||| lsb
      # Datasheet conversion: VOC index (0..500) ≈ raw / 65535 * 500
      voc_ppb = raw * 500 / 65_535
      {:ok, voc_ppb}
    end
  end
end
