defmodule WeatherTrackerWeb.Router do
  use WeatherTrackerWeb, :router

  # Suppress Dialyzer warnings for call/2
  @dialyzer {:nowarn_function, call: 2}

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", WeatherTrackerWeb do
    pipe_through(:api)

    post "/weather-conditions", WeatherConditionsController, :create
  end
end
