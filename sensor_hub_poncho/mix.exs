# sensor_hub_poncho/mix.exs
defmodule SensorHubPoncho.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",       # <- important! points to sub-app folders
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end
end
