defmodule Bme280.Converter do
  alias Bme280.Calibration

  @spec convert({integer, integer, integer}, Calibration.t()) ::
          %{temperature_c: float, pressure_pa: float, humidity_rh: float}
  def convert({adc_P, adc_T, adc_H}, calib) do
    {temp_c, t_fine} = compensate_temp(adc_T, calib)
    press_pa = compensate_press(adc_P, t_fine, calib)
    hum_pct = compensate_hum(adc_H, t_fine, calib)

    %{
      temperature_c: temp_c,
      pressure_pa: press_pa,
      humidity_rh: hum_pct
    }
  end

  defp compensate_temp(adc_T, calib) do
    var1 =
      (adc_T / 16384.0 - calib.dig_T1 / 1024.0) * calib.dig_T2

    var2 =
      (adc_T / 131_072.0 - calib.dig_T1 / 8192.0) *
        (adc_T / 131_072.0 - calib.dig_T1 / 8192.0) *
        calib.dig_T3

    t_fine = var1 + var2
    temperature = t_fine / 5120.0
    {temperature, t_fine}
  end

  defp compensate_press(adc_P, t_fine, calib) do
    var1 = t_fine / 2.0 - 64000.0
    var2 = var1 * var1 * calib.dig_P6 / 32768.0
    var2 = var2 + var1 * calib.dig_P5 * 2.0
    var2 = var2 / 4.0 + calib.dig_P4 * 65536.0
    var3 = calib.dig_P3 * var1 * var1 / 524_288.0
    var1 = (var3 + calib.dig_P2 * var1) / 524_288.0
    var1 = (1.0 + var1 / 32768.0) * calib.dig_P1

    if var1 == 0 do
      0
    else
      p = 1_048_576.0 - adc_P
      p = (p - var2 / 4096.0) * 6250.0 / var1
      var1 = calib.dig_P9 * p * p / 2_147_483_648.0
      var2 = p * calib.dig_P8 / 32768.0
      p + (var1 + var2 + calib.dig_P7) / 16.0
    end
  end

  defp compensate_hum(adc_H, t_fine, calib) do
    h = t_fine - 76800.0

    h =
      (adc_H - (calib.dig_H4 * 64.0 + calib.dig_H5 / 16384.0 * h)) *
        (calib.dig_H2 / 65536.0) *
        (1.0 +
           calib.dig_H6 / 67_108_864.0 * h *
             (1.0 + calib.dig_H3 / 67_108_864.0 * h))

    cond do
      h > 100.0 -> 100.0
      h < 0.0 -> 0.0
      true -> h
    end
  end
end
