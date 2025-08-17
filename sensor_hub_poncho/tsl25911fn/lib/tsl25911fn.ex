defmodule TSL25911FN do
  use GenServer

  require Logger

  alias TSL25911FN.{Comm, Config}

  @moduledoc """
  A GenServer for the TSL25911FN light sensor. It reads the light level
  and converts it to lumens based on the configuration provided.
  The sensor can be configured with different gain and integration times.
  """
  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def get_measurement do
    GenServer.call(__MODULE__, :get_measurement)
  end

  def measure do
    GenServer.call(__MODULE__, :measure)
  end

  def kill(reason \\ :normal) do
    GenServer.stop(__MODULE__, reason)
  end

  @doc """
  Starts the TSL25911FN GenServer with the given options. It will start the and then set an interval to
  read and then log the light reading every second.

  The second init function is used to discover the sensor on the I2C bus if no address is provided.
  """
  @impl true
  def init(%{address: address, i2c_bus_name: bus_name} = args) do
    i2c = Comm.open(bus_name)

    config =
      args
      |> Map.take([:gain, :int_time, :shutdown, :interrupt])
      |> Config.new()

    Comm.write_config(config, i2c, address)

    # Calculate integration time in milliseconds (example mapping)
    integration_ms =
      case config.int_time do
        :it_100_ms -> 100
        :it_200_ms -> 200
        :it_300_ms -> 300
        :it_400_ms -> 400
        :it_500_ms -> 500
        :it_600_ms -> 600
        _ -> 100
      end

    # Schedule first measure after integration time
    Process.send_after(self(), :measure, integration_ms)

    state = %{
      i2c: i2c,
      address: address,
      config: config,
      last_reading: :no_reading,
      integration_ms: integration_ms
    }

    {:ok, state}
  end

  def init(args) do
    {bus_name, address} = Comm.discover()
    transport = "bus: #{bus_name}, address: #{address}"
    Logger.info("Starting TSL25911FN. Please specify an address and a bus.")
    Logger.info("Starting on " <> transport)

    defaults =
      args
      |> Map.put(:address, address)
      |> Map.put(:i2c_bus_name, bus_name)

    init(defaults)
  end

  @doc """
  This are set to take the last reading from the sensor, then update the reading with the new reading and
  appending it to the state.
  """
  @impl true
  def handle_info(
        :measure,
        %{i2c: i2c, address: address, config: config, integration_ms: integration_ms} = state
      ) do
    last_reading = Comm.read(i2c, address, config)
    updated_state = %{state | last_reading: last_reading}

    # schedule next measurement after integration_ms milliseconds
    Process.send_after(self(), :measure, integration_ms)

    {:noreply, updated_state}
  end

  @doc """
  This is called when the GenServer is asked to measure the light level.
  It reads the sensor and returns the last reading.
  """
  @impl true
  def handle_call(:measure, _from, %{i2c: i2c, address: address} = state) do
    last_reading = Comm.read_raw(i2c, address)
    state = %{state | last_reading: last_reading}
    {:reply, state.last_reading, state}
  end

  @impl true
  def handle_call(:get_measurement, _from, state) do
    {:reply, state.last_reading, state}
  end

  @impl true
  def terminate(_reason, %{i2c: i2c}) do
    Logger.info("TSL25911FN GenServer terminating. Reason: #{inspect(reason)}")

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
end
