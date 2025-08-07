defmodule VEML6030 do
  use GenServer

  require Logger

  alias VEML6030.{Comm, Config}

  @moduledoc """
  A GenServer for the VEML6030 light sensor. It reads the light level
  and converts it to lumens based on the configuration provided.
  The sensor can be configured with different gain and integration times.
  """
  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def get_measurement do
    GenServer.call(__MODULE__, :get_measurement)
  end

  @doc """
  Starts the VEML6030 GenServer with the given options. It will start the and then set an interval to
  read and then log the light reading every second.
  """
  @impl true
  def init(%{address: address, i2c_bus_name: bus_name} = args) do
    i2c = Comm.open(bus_name)

    config =
      args
      |> Map.take([:gain, :int_time, :shutdown, :interrupt])
      |> Config.new()

    Comm.write_config(config, i2c, address)
    :timer.send_interval(1_000, :measure)

    state = %{
      i2c: i2c,
      address: address,
      config: config,
      last_reading: :no_reading
    }

    {:ok, state}
  end

  @doc """
  Starts the VEML6030 GenServer with the default configuration. This is for when you don't
  have the correct bus and address set.
  """
  def init(args) do
    {bus_name, address} = Comm.discover()
    transport = "bus: #{bus_name}, address: #{address}"
    Logger.info("Starting VEML6030. Please specify an address and a bus.")
    Logger.info("Starting on " <> transport)

    defaults =
      args
      |> Map.put(:address, address)
      |> Map.put(:i2c_bus_name, bus_name)

    init(defaults)
  end

  @doc """
  This are set to take the last reading froom the sensor, then update the reading with the new reading and
  appening it to the state.
  """
  @impl true
  def handle_info(:measure, %{i2c: i2c, address: address, config: config} = state) do
    last_reading = Comm.read(i2c, address, config)
    updated_with_reading = %{state | last_reading: last_reading}

    {:noreply, updated_with_reading}
  end

  @doc """
  This is for calling the GenServer to get the last reading from the sensor.
  """
  @impl true
  def handle_call(:get_measurement, _from, state) do
    {:reply, state.last_reading, state}
  end
end
