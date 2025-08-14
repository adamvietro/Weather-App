# defmodule LTR390UVTest do
#   use ExUnit.Case

#   alias LTR390_UV

#   setup do
#     {:ok, pid} =
#       LTR390_UV.start_link(%{
#         address: 0x53,
#         i2c_bus_name: "test_bus",
#         gain: :max,
#         resolution: :default,
#         uvs_als: :uvs,
#         measure_rate: :it_100_ms,
#         reset: false
#       })

#     %{pid: pid}
#   end

#   test "initial get_measurement returns :no_reading for both", %{pid: pid} do
#     assert GenServer.call(pid, :get_measurement) == {:no_reading, :no_reading}
#   end

#   test "get_measurement returns updated readings after measurements", %{pid: pid} do
#     send(pid, :measure)
#     # wait for async handle_info
#     Process.sleep(100)

#     {uvs, als} = GenServer.call(pid, :get_measurement)
#     assert uvs != :no_reading or als != :no_reading
#   end
# end
