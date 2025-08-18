defmodule Sgp40.Config do
  alias Sgp40.CrcHelper

  @measure_cmd <<0x26, 0x0F>>
  @default_humidity <<0x80, 0x00, 0xA2>>
  @default_temperature <<0x66, 0x66, 0x93>>

  defstruct humidity: nil,
            temperature: nil

  def new, do: struct(__MODULE__)

  def new(opts) do
    struct(__MODULE__, opts)
  end

  @doc """
  This will be responsible for the configuration byte.
  """
  def measure_frame(%__MODULE__{humidity: nil, temperature: nil}) do
    @measure_cmd <> @default_humidity <> @default_temperature
  end

  def measure_frame(%__MODULE__{humidity: hum, temperature: temp}) do
    hum_bytes = CrcHelper.encode_with_crc(hum)
    temp_bytes = CrcHelper.encode_with_crc(temp)
    @measure_cmd <> hum_bytes <> temp_bytes
  end

  def soft_reset do
    <<0x00, 0x06>>
  end

  def self_test do
    <<0x28, 0x0E>>
  end
end
