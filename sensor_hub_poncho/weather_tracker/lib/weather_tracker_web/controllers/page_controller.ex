# lib/weather_tracker_web/controllers/page_controller.ex
defmodule WeatherTrackerWeb.PageController do
  use WeatherTrackerWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.dashboard_path(conn, :index))
  end
end
