defmodule TSL25911FN.Config do
  import Bitwise

  defstruct gain: :gain_1_4th,
            int_time: :it_100_ms,
            shutdown: false,
            interrupt: false

  def new, do: struct(__MODULE__)

  def new(opts) do
    struct(__MODULE__, opts)
  end

  # This is the version of the to_integer function that we will use for the VEML6030 sensor.
  # We don't have that.
  # def to_integer(config) do
  #   reserved = 0
  #   persistence_protect = 0

  #   <<integer::16>> = <<
  #     reserved::3,
  #     gain(config.gain)::2,
  #     reserved::1,
  #     int_time(config.int_time)::4,
  #     persistence_protect::2,
  #     reserved::2,
  #     interrupt(config.interrupt)::1,
  #     shutdown(config.shutdown)::1
  #   >>

  #   integer
  # end

  # We will need to use an other version of hte to_integer function
  def to_control_byte(%__MODULE__{gain: gain, int_time: int_time}) do
    gain(gain) <<< 4 ||| int_time(int_time)
  end

  def to_enable_byte(%__MODULE__{shutdown: shutdown, interrupt: interrupt}) do
    interrupt(interrupt) <<< 4 ||| 1 <<< 1 ||| shutdown(shutdown)
  end

  defp gain(:low), do: 0b00
  defp gain(:med), do: 0b01
  defp gain(:high), do: 0b10
  defp gain(:max), do: 0b11
  defp gain(:gain_default), do: 0b11

  defp int_time(:it_100_ms), do: 0b000
  defp int_time(:it_200_ms), do: 0b001
  defp int_time(:it_300_ms), do: 0b010
  defp int_time(:it_400_ms), do: 0b011
  defp int_time(:it_500_ms), do: 0b100
  defp int_time(:it_600_ms), do: 0b101
  defp int_time(:it_default), do: 0b000
  defp shutdown(true), do: 1
  defp shutdown(_), do: 0
  defp interrupt(true), do: 1
  defp interrupt(_), do: 0

  # There's more to this lumens factor map. For the full listing see
  # the nerves_code/veml6030/lib/veml6030/config.ex file in the
  # https://github.com/akoutmos/nerves_weather_station repo.
  @to_lumens_factor %{
    {:it_100_ms, :low} => 0.0288,
    {:it_100_ms, :med} => 0.0576,
    {:it_100_ms, :high} => 0.2304,
    {:it_100_ms, :max} => 0.4608,
    {:it_200_ms, :low} => 0.0144,
    {:it_200_ms, :med} => 0.0288,
    {:it_200_ms, :high} => 0.1152,
    {:it_200_ms, :max} => 0.2304,
    {:it_300_ms, :low} => 0.0108,
    {:it_300_ms, :med} => 0.0216,
    {:it_300_ms, :high} => 0.0864,
    {:it_300_ms, :max} => 0.1728,
    {:it_400_ms, :low} => 0.0072,
    {:it_400_ms, :med} => 0.0144,
    {:it_400_ms, :high} => 0.0576,
    {:it_400_ms, :max} => 0.1152,
    {:it_500_ms, :low} => 0.0063,
    {:it_500_ms, :med} => 0.0126,
    {:it_500_ms, :high} => 0.0504,
    {:it_500_ms, :max} => 0.1008,
    {:it_600_ms, :low} => 0.0054,
    {:it_600_ms, :med} => 0.0108,
    {:it_600_ms, :high} => 0.0432,
    {:it_600_ms, :max} => 0.0864
  }

  # def to_lumens(config, measurement) do
  #   @to_lumens_factor[{config.int_time, config.gain}] * measurement
  # end

  def to_lumens(%{int_time: it, gain: gain}, ch0, ch1) do
    key = {it, gain}

    factor =
      Map.get(@to_lumens_factor, key) ||
        raise ArgumentError, "Unsupported integration_time/gain combination: #{inspect(key)}"

    lux = ch0 - ch1
    max(lux * factor, 0.0)
  end
end
