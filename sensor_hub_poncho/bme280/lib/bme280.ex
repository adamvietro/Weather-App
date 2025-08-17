defmodule Bme280 do
  use GenServer

  require Logger

  alias Bme280.Comm
  alias Bme280.Calibration
  alias Bme280.Config
  alias Bme280.Converter

  @moduledoc """
  Documentation for `Bme280` Temperature, Humidity, and Pressure sensor. It
  will take raw measurements and then convert them to human-readable values.
  There are different calibration parameters that need to be taken into account
  for accurate readings.
  """

  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def read() do
    GenServer.cast(__MODULE__, :read)
  end

  def get_measurement(pressure_unit \\ :pa) do
    GenServer.call(__MODULE__, {:get_measurement, pressure_unit})
  end

  def read_calibration() do
    GenServer.call(__MODULE__, :read_calibration)
  end

  def read_raw() do
    GenServer.call(__MODULE__, :read_raw)
  end

  def measure_now() do
    GenServer.call(__MODULE__, :measure_now)
  end

  def kill(reason \\ :normal) do
    case reason do
      :normal -> Logger.info("Terminating BME280 sensor normally.")
      _ -> Logger.error("Terminating BME280 sensor with reason: #{inspect(reason)}")
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

    config =
      args
      |> Map.take([:mode, :osrs_h, :osrs_p, :osrs_t, :filter, :standby_time, :spi3w_en])
      |> Config.new()

    Comm.write_config(config, i2c, address)

    calibration = Calibration.read_all(i2c, address)
    integration_ms = Config.integration_ms(config)

    # Schedule first measure after integration time
    Process.send_after(self(), :read, integration_ms)

    state = %{
      i2c: i2c,
      address: address,
      config: config,
      calibration: calibration,
      last_raw_reading: :no_reading,
      last_reading: :no_reading,
      integration_ms: integration_ms
    }

    {:ok, state}
  end

  def init(args) do
    {bus_name, address} = Comm.discover()
    transport = "bus: #{bus_name}, address: #{address}"
    Logger.info("Starting BME280. Please specify an address and a bus.")
    Logger.info("Starting on " <> transport)

    defaults =
      args
      |> Map.put(:address, address)
      |> Map.put(:i2c_bus_name, bus_name)

    init(defaults)
  end

  @impl true
  def handle_info(
        :read,
        %{i2c: i2c, address: address, calibration: calibration, integration_ms: integration_ms} =
          state
      ) do
    last_reading = Comm.read(i2c, address)
    last_reading = Converter.convert(last_reading, calibration)
    updated_state = %{state | last_reading: last_reading}

    # IO.inspect(updated_state.last_reading, label: "BME280 Reading")

    Process.send_after(self(), :read, integration_ms)

    {:noreply, updated_state}
  end

  @impl true
  def handle_call({:get_measurement, pressure_unit}, _from, state) do
    {:reply, %{last_reading: convert_pressure_units(state.last_reading, pressure_unit)}, state}
  end

  @impl true
  def handle_call(:read_raw, _from, state) do
    {:reply, state.last_raw_reading, state}
  end

  @impl true
  def handle_call(:read_calibration, _from, state) do
    {:reply, state.calibration, state}
  end

  @impl true
  def handle_call(
        :measure_now,
        _from,
        %{i2c: i2c, address: address, calibration: cal, config: config} = state
      ) do
    # 1. Set sensor to forced mode
    forced_config = %{config | mode: :forced}
    Comm.write_config(forced_config, i2c, address)

    # 2. Wait for integration time
    :timer.sleep(Config.integration_ms(forced_config))

    # 3. Read raw data
    raw = Comm.read(i2c, address)

    # 4. Convert to human-readable
    converted = Converter.convert(raw, cal)

    # 5. Update state
    {:reply, converted,
     %{state | last_raw_reading: raw, last_reading: converted, config: forced_config}}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("BME280 GenServer terminating. Reason: #{inspect(reason)}")

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

  defp convert_pressure_units(reading, :pa), do: reading

  defp convert_pressure_units(%{pressure_pa: pa} = reading, :hpa),
    do: %{reading | pressure_pa: pa / 100}

  defp convert_pressure_units(%{pressure_pa: pa} = reading, :inhg),
    do: %{reading | pressure_pa: pa / 3386.389}
end
