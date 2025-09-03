defmodule WeatherTrackerWeb.Router do
  use WeatherTrackerWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", WeatherTrackerWeb do
    pipe_through(:browser)

    get("/dashboard", DashboardController, :index)
  end

  scope "/api", WeatherTrackerWeb do
    pipe_through(:api)

    post("/weather-conditions", WeatherConditionsController, :create)
  end
end
