defmodule Bme280 do
  use GenServer

  require Logger

  alias Bme280.Comm
  alias Bme280.Calibration
  alias Bme280.Config

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
    GenServer.call(__MODULE__, :read)
  end

  def read_calibration() do
    GenServer.call(__MODULE__, :read_calibration)
  end

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
    Process.send_after(self(), :measure, integration_ms)

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
  def handle_info(:measure, %{i2c: i2c, address: address, integration_ms: ms} = state) do
    raw = Comm.read(i2c, address)

    # Schedule next measurement
    Process.send_after(self(), :measure, ms)

    {:noreply, %{state | last_raw_reading: raw}}
  end

  @impl true
  def handle_call(:read, _from, state) do
    {:reply, %{last_reading: state.last_reading, raw_reading: state.last_raw_reading}, state}
  end

  @impl true
  def handle_call(:read_calibration, _from, state) do
    {:reply, state.calibration, state}
  end
end
