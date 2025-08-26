defmodule SensorHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options

    children =
      children([]) ++ target_children()

    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Children based on target
  def children(:host) do
    # Nothing or host-safe workers
    []
  end

  def children(_target) do
    # This function returns the child processes to be supervised
    # Here you can define the children for your application
    [
      {Bme280, %{}},
      {SGP40, %{bus_name: "i2c-1", name: SGP40}},
      {TSL25911FN, %{}},
      {LTR390_UV, %{}}
    ]
  end

  # List all child processes to be supervised
  if Mix.target() == :host do
    defp target_children() do
      [
        # Children that only run on the host during development or test.
        # In general, prefer using `config/host.exs` for differences.
        #
        # Starts a worker by calling: Host.Worker.start_link(arg)
        # {Host.Worker, arg},
      ]
    end
  else
    defp target_children() do
      [
        # Children for all targets except host
        # Starts a worker by calling: Target.Worker.start_link(arg)
        # {Target.Worker, arg},
      ]
    end
  end
end
