defmodule Sgp40 do
  use GenServer

  require Logger

  alias Sgp40.Comm
  alias Sgp40.Config
  alias Sgp40.CrcHelper

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

    config =
      args
      |> Map.take([:temperature, :humidity])
      |> Config.new()

    Comm.initialize_sensor(i2c, address)

    Process.send_after(self(), :measure, 50)

    state = %{
      i2c: i2c,
      address: address,
      config: config,
      last_reading: :no_reading
    }

    {:ok, state}
  end

  def init(args) do
    {bus_name, address} = Comm.discover()
    transport = "bus: #{bus_name}, address: #{address}"
    Logger.info("Starting SGP40. Please specify an address and a bus.")
    Logger.info("Starting on " <> transport)

    defaults =
      args
      |> Map.put(:address, address)
      |> Map.put(:i2c_bus_name, bus_name)

    init(defaults)
  end

  def handle_info(:measure, %{i2c: i2c, address: address} = state) do
    last_reading = Comm.measure(i2c, address, state.config)

    Process.send_after(self(), :measure, 50)

    {:noreply, %{state | last_reading: last_reading}}
  end

  @impl true
  def terminate(reason, %{i2c: i2c} = state) do
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
end
