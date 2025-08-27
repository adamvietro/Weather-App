defmodule WeatherTracker.WeatherConditions do
  alias WeatherTracker.{WeatherConditions.WeatherCondition, Repo}

  def create_weather_condition(attrs) do
    %WeatherCondition{}
    |> WeatherCondition.create_changeset(attrs)
    |> Repo.insert()
  end
end
