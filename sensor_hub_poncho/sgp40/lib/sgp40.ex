defmodule Sgp40 do
  use GenServer

  require Logger

  alias Sgp40.Comm
  alias Sgp40.Config
  alias Sgp40.CrcHelper
  alias Sgp40.Converter
  alias Bme280

  @moduledoc """
  Documentation for `Sgp40` Indoor Air Quality Sensor. It will take some measurements and provide air quality data.
  You will need some calibrations for the sensor to get proper readings. You will need to have a
  Temperature and Humidity readings from other sensors to get the best readings. If you don't have
  those readings, there will be a some standard settings that will be used.
  """

  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def measure() do
    GenServer.cast(__MODULE__, :measure)
  end

  def get_measurement() do
    GenServer.call(__MODULE__, :get_measurement)
  end

  def kill(reason \\ :normal) do
    case reason do
      :normal -> Logger.info("Terminating SGP40 sensor normally.")
      _ -> Logger.error("Terminating SGP40 sensor with reason: #{inspect(reason)}")
    end

    GenServer.stop(__MODULE__, reason)
  end

  @doc """
  Initiates the basic settings for the BME280 sensor. The standards can be set within the
  config.ex.
  """
  @impl true
  def init(%{address: address, i2c_bus_name: bus_name} = args) do
    i2c = Comm.open(bus_name)
    config = Config.new(args) |> maybe_update_config()

    case init_sensor_with_retry(i2c, address, 3) do
      {:ok, :test_passed} ->
        Process.send_after(self(), :measure, 100)

        state = %{
          i2c: i2c,
          address: address,
          config: config,
          last_reading: :no_reading,
          last_raw_reading: :no_reading
        }

        {:ok, state}

      {:error, reason} ->
        Logger.error("SGP40 failed to initialize after retries: #{inspect(reason)}")
        {:stop, {:sensor_init_failed, reason}}
    end
  end

  def init(args) do
    # Hardcoded bus and address
    bus_name = "i2c-1"
    address = 0x59
    transport = "bus: #{bus_name}, address: #{address}"
    Logger.info("Starting SGP40. Please specify an address and a bus.")
    Logger.info("Starting on " <> transport)

    defaults =
      args
      |> Map.put(:address, address)
      |> Map.put(:i2c_bus_name, bus_name)

    init(defaults)
  end

  @impl true
  def handle_info(:measure, %{i2c: i2c, address: address} = state) do
    config = maybe_update_config(state.config)

    case Comm.measure(i2c, address, config) do
      {:ok, raw} ->
        last_reading = CrcHelper.decode_voc(raw)
        Process.send_after(self(), :measure, 50)
        {:noreply, %{state | last_reading: last_reading, last_raw_reading: raw, config: config}}

      {:error, reason} ->
        Logger.error("SGP40 measurement failed: #{inspect(reason)}")
        Process.send_after(self(), :measure, 50)
        {:noreply, state}
    end
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("SGP40 GenServer terminating. Reason: #{inspect(reason)}")

    # Clean up I2C bus if it's open
    case state do
      %{i2c: i2c} when not is_nil(i2c) ->
        Comm.close(i2c)
        Logger.info("Closed I2C connection.")

      _ ->
        Logger.warning("No I2C connection found to close.")
    end

    :ok
  end

  @impl true
  def handle_call(:get_measurement, _from, %{last_reading: last_reading} = state) do
    {:reply, last_reading, state}
  end

  defp maybe_update_config(nil), do: nil

  defp maybe_update_config(config) do
    case Process.whereis(Bme280) do
      nil ->
        config

      _pid ->
        case Bme280.get_measurement() do
          %{last_reading: nil} ->
            config

          %{last_reading: %{temperature_c: temp, humidity_rh: hum}} ->
            {temp_tuple, hum_tuple} = Converter.human_to_tuple(temp, hum)
            %{config | temperature: temp_tuple, humidity: hum_tuple}

          _ ->
            # fallback in case the structure is unexpected
            config
        end
    end
  end

  defp init_sensor_with_retry(_i2c, _address, 0), do: {:error, :max_retries}

  defp init_sensor_with_retry(i2c, address, attempts_left) do
    case Comm.initialize_sensor(i2c, address) do
      {:ok, :test_passed} ->
        {:ok, :test_passed}

      {:error, reason} ->
        Logger.warning(
          "SGP40 init failed (#{inspect(reason)}), #{attempts_left - 1} retries left"
        )

        :timer.sleep(50)
        init_sensor_with_retry(i2c, address, attempts_left - 1)
    end
  end
end
