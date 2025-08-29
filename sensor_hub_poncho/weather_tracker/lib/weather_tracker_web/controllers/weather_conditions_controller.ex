defmodule WeatherTrackerWeb.WeatherConditionsController do
  use WeatherTrackerWeb, :controller

  require Logger

  alias WeatherTracker.{
    WeatherConditions,
    WeatherConditions.WeatherCondition
  }

  def create(conn, params) do
    IO.inspect(params)
    case WeatherConditions.create_entry(params) do
      {:ok, weather_condition = %WeatherCondition{}} ->
        Logger.debug("Successfully created weather condition: #{inspect(weather_condition)}")

        conn
        |> put_status(:created)
        |> json(weather_condition)

      error ->
        Logger.warning("Failed to create weather condition: #{inspect(error)}")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{message: "Poorly formatted payload"})
    end
  end
end
