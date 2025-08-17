defmodule LTR390_UV do
  use GenServer

  require Logger

  alias LTR390_UV.{Comm, Config}

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
  Starts the LTSR390_UV GenServer with the given options. It will start the and then set an interval to
  read and then log the light reading every second.

  The second init function is used to discover the sensor on the I2C bus if no address is provided.
  """
  @impl true
  def init(%{address: address, i2c_bus_name: bus_name} = args) do
    i2c = Comm.open(bus_name)

    config =
      args
      |> Map.take([:gain, :resolution, :uvs_als, :measure_rate, :reset])
      |> Config.new()

    Comm.write_config(config, i2c, address)

    # Calculate measure rate in milliseconds (example mapping)
    measure_rate =
      case config.measure_rate do
        :it_25_ms -> 25
        :it_50_ms -> 50
        :it_100_ms -> 100
        :it_200_ms -> 200
        :it_500_ms -> 500
        :it_1000_ms -> 1000
        :it_2000_ms -> 2000
        _ -> 100
      end

    # Schedule first measure after measure_rate
    Process.send_after(self(), :measure, measure_rate)

    state = %{
      i2c: i2c,
      address: address,
      config: config,
      resolution: config.resolution,
      measure_rate: measure_rate,
      reset: config.reset,
      gain: config.gain,
      uvs_als: config.uvs_als,
      last_uvs: :no_reading,
      last_als: :no_reading
    }

    {:ok, state}
  end

  def init(args) do
    {bus_name, address} = Comm.discover()
    transport = "bus: #{bus_name}, address: #{address}"
    Logger.info("Starting LTR390_UV. Please specify an address and a bus.")
    Logger.info("Starting on " <> transport)

    defaults =
      args
      |> Map.put(:address, address)
      |> Map.put(:i2c_bus_name, bus_name)

    init(defaults)
  end

  @doc """
  This are set to take the last reading from the sensor, then update the reading with the new reading and
  appending it to the state. Once that is done it will switch to the other type of sensor and schedule an other
  reading.
  """
  @impl true
  def handle_info(
        :measure,
        %{
          i2c: i2c,
          address: address,
          config: config,
          measure_rate: measure_rate,
          uvs_als: current_mode
        } = state
      ) do
    last_reading = Comm.read(i2c, address, config)

    # Toggle mode and update config accordingly
    {new_state, new_config} =
      case current_mode do
        :uvs ->
          {%{state | last_uvs: last_reading, uvs_als: :als}, %{config | uvs_als: :als}}

        :als ->
          {%{state | last_als: last_reading, uvs_als: :uvs}, %{config | uvs_als: :uvs}}
      end

    # Write new config to switch sensor mode
    Comm.write_config(new_config, i2c, address)

    # Wait a few moments to let the sensor change
    Process.sleep(measure_rate)

    # Schedule next measurement after full measure_rate
    Process.send_after(self(), :measure, measure_rate)

    {:noreply, %{new_state | config: new_config}}
  end

  @impl true
  def handle_call(:measure, _from, %{i2c: i2c, address: address, config: config} = state) do
    # Read fresh sensor data
    last_reading = Comm.read(i2c, address, config)

    # Update state depending on current mode (uvs or als)
    new_state =
      case state.uvs_als do
        :uvs -> %{state | last_uvs: last_reading}
        :als -> %{state | last_als: last_reading}
      end

    {:reply, last_reading, new_state}
  end

  @doc """
  This is called when the GenServer is asked to get the last measurements for both uvs and als.
  """
  @impl true
  def handle_call(:get_measurement, _from, state) do
    last_uvs = state.last_uvs
    last_als = state.last_als
    {:reply, {last_uvs, last_als}, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("LTR390_UV GenServer terminating. Reason: #{inspect(reason)}")

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
