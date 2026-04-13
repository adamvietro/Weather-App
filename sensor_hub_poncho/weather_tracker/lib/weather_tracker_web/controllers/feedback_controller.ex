defmodule WeatherTrackerWeb.FeedbackController do
  require Logger

  use WeatherTrackerWeb, :controller
  alias WeatherTracker.WeatherConditions
  alias WeatherTrackerWeb.FeedbackInformation

  def index(conn, params) do
    limit = Map.get(params, "limit", 10)

    weather_conditions =
      WeatherConditions.get_latest_entries(limit)

    Logger.debug("Fetching latest weather conditions: #{inspect(hd(weather_conditions))}")
    render(conn, "index.html", weather_conditions: weather_conditions)
  end
end
