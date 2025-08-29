defmodule WeatherTracker.WeatherConditions.WeatherCondition do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed_fields [
    :temperature_c,
    :pressure_pa,
    :humidity_rh,
    :light_lumens,
    :voc_index,
    :uv_index,
    :als_lux
  ]

  @derive {Jason.Encoder, only: @allowed_fields}
  @primary_key false

  schema "weather_conditions" do
    field :timestamp, :naive_datetime
    field :temperature_c, :decimal
    field :pressure_pa, :decimal
    field :humidity_rh, :decimal
    field :light_lumens, :decimal
    field :voc_index, :decimal
    field :uv_index, :decimal
    field :als_lux, :decimal
  end

  def create_changeset(weather_condition = %__MODULE__{}, attrs) do
    timestamp =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    weather_condition
    |> cast(attrs, @allowed_fields)
    |> validate_required(@allowed_fields)
    |> put_change(:timestamp, timestamp)
  end
end
