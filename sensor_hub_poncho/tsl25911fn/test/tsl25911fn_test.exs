defmodule TSL25911FNTest do
  use ExUnit.Case, async: true

  alias TSL25911FN

  setup do
    # Setup code for starting the GenServer with mock dependencies
    # Possibly mock Comm.open/1 and Comm.read_raw/3 etc.
    :ok
  end

  describe "start_link/1 and init/1" do
    test "starts GenServer and initializes state" do
      # Start the GenServer with known config
      # Assert state fields like last_reading, integration_ms, etc.
    end
  end

  describe "handle_call(:measure)" do
    test "returns the last raw measurement" do
      # Mock Comm.read_raw/3 to return a known tuple
      # Call measure and assert it returns that tuple
    end
  end

  describe "handle_call(:get_measurement)" do
    test "returns the last reading from state" do
      # Call get_measurement and assert it returns expected value
    end
  end

  describe "handle_info(:measure)" do
    test "reads sensor and updates state" do
      # Mock Comm.read/3 to return known value
      # Send :measure message and assert state update and Process.send_after called
    end
  end
end
