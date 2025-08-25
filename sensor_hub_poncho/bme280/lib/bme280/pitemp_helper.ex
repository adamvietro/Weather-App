defmodule Bme280.PiTemp.Helper do
  @moduledoc "Read the Raspberry Pi CPU temperature."

  def get_cpu_temp_c do
    case File.read("/sys/class/thermal/thermal_zone0/temp") do
      {:ok, contents} ->
        contents
        |> String.trim()
        |> String.to_integer()
        |> Kernel./(1000)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
