defmodule WeatherTracker.WeatherConditions do
  import Ecto.Query
  alias WeatherTracker.{WeatherConditions.WeatherCondition, Repo}

  def create_entry(attrs) do
    %WeatherCondition{}
    |> WeatherCondition.create_changeset(attrs)
    |> Repo.insert()
  end

  def get_latest_entries(limit \\ 10) do
    WeatherCondition
    |> order_by(desc: :timestamp)
    |> limit(^limit)
    |> Repo.all()
  end
end
